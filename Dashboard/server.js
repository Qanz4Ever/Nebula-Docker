const express = require('express');
const { exec } = require('child_process');
const path = require('path');
const os = require('os');
const fs = require('fs');
const app = express();
const PORT = 3000;

// Middleware
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Get network interfaces
function getNetworkIPs() {
    const interfaces = os.networkInterfaces();
    const ips = [];
    
    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            if (iface.family === 'IPv4' && !iface.internal) {
                ips.push(iface.address);
            }
        }
    }
    
    return ips;
}

// Helper function to execute docker commands
const execCommand = (command) => {
    return new Promise((resolve, reject) => {
        exec(command, { maxBuffer: 1024 * 1024 }, (error, stdout, stderr) => {
            if (error) {
                reject({ error: error.message, stderr });
            } else {
                resolve(stdout.trim());
            }
        });
    });
};

// API Routes

// Get all containers
app.get('/api/containers', async (req, res) => {
    try {
        const containers = [];
        
        // Get all container names
        const { stdout } = await new Promise((resolve, reject) => {
            exec('docker ps -a --format "{{.Names}}"', (err, stdout, stderr) => {
                if (err) reject(err);
                else resolve({ stdout, stderr });
            });
        });
        
        const names = stdout.split('\n').filter(n => n.trim());
        
        for (const name of names) {
            // Get container details
            const [status, image, created, ports] = await Promise.all([
                execCommand(`docker inspect --format='{{.State.Status}}' ${name}`),
                execCommand(`docker inspect --format='{{.Config.Image}}' ${name}`),
                execCommand(`docker inspect --format='{{.Created}}' ${name}`),
                execCommand(`docker port ${name}`).catch(() => '')
            ]);
            
            // Get stats if running
            let cpu = '0%', memory = '0B / 0B';
            if (status === 'running') {
                const stats = await execCommand(`docker stats --no-stream --format "{{.CPUPerc}}|{{.MemUsage}}" ${name}`).catch(() => '');
                if (stats) {
                    const [c, m] = stats.split('|');
                    cpu = c || '0%';
                    memory = m || '0B / 0B';
                }
            }
            
            containers.push({
                name,
                status,
                image,
                created: created.split('T')[0],
                cpu,
                memory,
                ports: ports || 'No ports',
                running: status === 'running'
            });
        }
        
        res.json({
            containers,
            total: containers.length,
            running: containers.filter(c => c.running).length
        });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ error: 'Failed to list containers' });
    }
});

// Container operations
app.post('/api/container/:action/:name', async (req, res) => {
    const { action, name } = req.params;
    const validActions = ['start', 'stop', 'restart', 'delete'];
    
    if (!validActions.includes(action)) {
        return res.status(400).json({ error: 'Invalid action' });
    }
    
    try {
        if (action === 'delete') {
            await execCommand(`docker stop ${name}`).catch(() => {});
            await execCommand(`docker rm ${name}`);
        } else {
            await execCommand(`docker ${action} ${name}`);
        }
        
        res.json({ success: true, message: `Container ${action}ed successfully` });
    } catch (error) {
        res.status(500).json({ error: `Failed to ${action} container: ${error.message}` });
    }
});

// Create container
app.post('/api/container/create', async (req, res) => {
    const { name, image, cpu, memory, ports, volumes, env } = req.body;
    
    let cmd = `docker run -dit --name ${name}`;
    
    if (cpu) cmd += ` --cpus ${cpu}`;
    if (memory) cmd += ` --memory ${memory}M`;
    if (ports) {
        ports.split(',').forEach(p => {
            cmd += ` -p ${p.trim()}`;
        });
    }
    if (volumes) {
        volumes.split(',').forEach(v => {
            cmd += ` -v ${v.trim()}`;
        });
    }
    if (env) {
        env.split(',').forEach(e => {
            cmd += ` -e ${e.trim()}`;
        });
    }
    
    cmd += ` ${image}`;
    
    // Add command based on image
    if (image.includes('mysql')) {
        cmd += ' --mysql-native-password=ON';
    } else if (image.includes('postgres')) {
        cmd += ' postgres';
    } else if (image.includes('nginx')) {
        cmd += ' nginx -g "daemon off;"';
    } else if (image.includes('redis')) {
        cmd += ' redis-server';
    } else {
        cmd += ' bash';
    }
    
    try {
        await execCommand(cmd);
        res.json({ success: true, message: 'Container created successfully' });
    } catch (error) {
        res.status(500).json({ error: `Failed to create container: ${error.message}` });
    }
});

// Get container logs
app.get('/api/container/logs/:name', async (req, res) => {
    const { name } = req.params;
    const { lines = 100 } = req.query;
    
    try {
        const logs = await execCommand(`docker logs --tail ${lines} ${name}`);
        res.json({ logs });
    } catch (error) {
        res.status(500).json({ error: 'Failed to get logs' });
    }
});

// System info
app.get('/api/system', (req, res) => {
    const totalMem = os.totalmem();
    const freeMem = os.freemem();
    
    res.json({
        hostname: os.hostname(),
        platform: os.platform(),
        arch: os.arch(),
        uptime: os.uptime(),
        memory: {
            total: (totalMem / 1024 / 1024 / 1024).toFixed(2) + ' GB',
            free: (freeMem / 1024 / 1024 / 1024).toFixed(2) + ' GB',
            used: ((totalMem - freeMem) / 1024 / 1024 / 1024).toFixed(2) + ' GB'
        },
        cpus: os.cpus().length,
        loadavg: os.loadavg(),
        ips: getNetworkIPs()
    });
});

// Get available images
app.get('/api/images', (req, res) => {
    const images = [
        { name: 'Ubuntu 22.04', value: 'ubuntu:22.04' },
        { name: 'Ubuntu 20.04', value: 'ubuntu:20.04' },
        { name: 'Debian 12', value: 'debian:12' },
        { name: 'Debian 11', value: 'debian:11' },
        { name: 'CentOS 9', value: 'centos:stream9' },
        { name: 'Alpine 3.19', value: 'alpine:3.19' },
        { name: 'Fedora 39', value: 'fedora:39' },
        { name: 'Arch Linux', value: 'archlinux:latest' },
        { name: 'Python 3.12', value: 'python:3.12-slim' },
        { name: 'Node.js 20', value: 'node:20-slim' },
        { name: 'Nginx', value: 'nginx:alpine' },
        { name: 'MySQL 8.0', value: 'mysql:8.0' },
        { name: 'PostgreSQL 16', value: 'postgres:16' },
        { name: 'Redis 7', value: 'redis:7-alpine' }
    ];
    res.json(images);
});

// Serve index.html for all other routes
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Error handler
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Something went wrong!' });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log('╔════════════════════════════════════════════╗');
    console.log('║         Nebula Docker Web Panel           ║');
    console.log('║         Created By © Mfsavana 2026        ║');
    console.log('╚════════════════════════════════════════════╝');
    console.log(`\n📡 Server running at:`);
    console.log(`   Local:   http://localhost:${PORT}`);
    getNetworkIPs().forEach(ip => {
        console.log(`   Network: http://${ip}:${PORT}`);
    });
    console.log('\n📊 Manage your Docker containers easily!');
});
