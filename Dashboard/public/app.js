// Global variables
let containers = [];
let refreshInterval;
let countdown = 5;
let systemInfo = {};

// DOM Elements
const tableBody = document.getElementById('tableBody');
const totalContainersEl = document.getElementById('totalContainers');
const runningContainersEl = document.getElementById('runningContainers');
const stoppedContainersEl = document.getElementById('stoppedContainers');
const systemInfoEl = document.getElementById('systemInfo');
const systemBar = document.getElementById('systemBar');
const refreshCountdown = document.getElementById('refreshCountdown');
const currentTimeEl = document.getElementById('currentTime');

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    loadImages();
    fetchContainers();
    fetchSystemInfo();
    startAutoRefresh();
    updateCurrentTime();
    setInterval(updateCurrentTime, 1000);
});

// Update current time
function updateCurrentTime() {
    const now = new Date();
    const options = { 
        hour: '2-digit', 
        minute: '2-digit', 
        second: '2-digit',
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
    };
    currentTimeEl.textContent = now.toLocaleDateString('id-ID', options);
}

// Load available images
async function loadImages() {
    try {
        const response = await fetch('/api/images');
        const images = await response.json();
        
        const select = document.getElementById('containerImage');
        images.forEach(img => {
            const option = document.createElement('option');
            option.value = img.value;
            option.textContent = img.name;
            select.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading images:', error);
    }
}

// Fetch containers
async function fetchContainers() {
    try {
        const response = await fetch('/api/containers');
        const data = await response.json();
        
        containers = data.containers || [];
        updateStats(data);
        renderTable();
    } catch (error) {
        showToast('Error loading containers', 'error');
        console.error('Error:', error);
    }
}

// Fetch system info
async function fetchSystemInfo() {
    try {
        const response = await fetch('/api/system');
        systemInfo = await response.json();
        updateSystemInfo();
    } catch (error) {
        console.error('Error loading system info:', error);
    }
}

// Update system info display
function updateSystemInfo() {
    document.getElementById('hostname').innerHTML = `<i class="fas fa-server"></i> ${systemInfo.hostname}`;
    document.getElementById('memoryUsage').innerHTML = `<i class="fas fa-memory"></i> Memory: ${systemInfo.memory.used} / ${systemInfo.memory.total}`;
    document.getElementById('cpuCores').innerHTML = `<i class="fas fa-microchip"></i> CPU: ${systemInfo.cpus} cores`;
    document.getElementById('ipAddress').innerHTML = `<i class="fas fa-network-wired"></i> IP: ${systemInfo.ips[0] || 'N/A'}`;
    
    systemInfoEl.innerHTML = `<i class="fas fa-chart-line"></i> Load: ${systemInfo.loadavg[0].toFixed(2)}`;
}

// Update statistics
function updateStats(data) {
    totalContainersEl.textContent = data.total || 0;
    runningContainersEl.textContent = data.running || 0;
    stoppedContainersEl.textContent = (data.total - data.running) || 0;
}

// Render table
function renderTable() {
    if (containers.length === 0) {
        tableBody.innerHTML = `
            <tr>
                <td colspan="8" class="loading">
                    <i class="fas fa-docker"></i> No containers found. Create one!
                </td>
            </tr>
        `;
        return;
    }

    tableBody.innerHTML = containers.map(container => {
        const statusClass = getStatusClass(container.status);
        const isRunning = container.status === 'running';
        
        return `
            <tr>
                <td><strong>${container.name}</strong></td>
                <td>
                    <span class="status-badge ${statusClass}">
                        <i class="fas fa-${isRunning ? 'play' : 'stop'}"></i>
                        ${container.status}
                    </span>
                </td>
                <td>${container.image}</td>
                <td>${container.created}</td>
                <td>${container.cpu}</td>
                <td>${container.memory.split('/')[0]}</td>
                <td>${container.ports.substring(0, 30)}${container.ports.length > 30 ? '...' : ''}</td>
                <td>
                    <div class="action-buttons">
                        <button class="action-btn start" onclick="controlContainer('start', '${container.name}')" 
                                ${isRunning ? 'disabled' : ''} title="Start">
                            <i class="fas fa-play"></i>
                        </button>
                        <button class="action-btn stop" onclick="controlContainer('stop', '${container.name}')" 
                                ${!isRunning ? 'disabled' : ''} title="Stop">
                            <i class="fas fa-stop"></i>
                        </button>
                        <button class="action-btn restart" onclick="controlContainer('restart', '${container.name}')" 
                                ${!isRunning ? 'disabled' : ''} title="Restart">
                            <i class="fas fa-sync-alt"></i>
                        </button>
                        <button class="action-btn logs" onclick="viewLogs('${container.name}')" title="Logs">
                            <i class="fas fa-terminal"></i>
                        </button>
                        <button class="action-btn delete" onclick="deleteContainer('${container.name}')" title="Delete">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </td>
            </tr>
        `;
    }).join('');
}

// Get status badge class
function getStatusClass(status) {
    switch(status) {
        case 'running': return 'status-running';
        case 'exited':
        case 'dead': return 'status-exited';
        case 'paused': return 'status-paused';
        default: return 'status-exited';
    }
}

// Control container
async function controlContainer(action, name) {
    try {
        const response = await fetch(`/api/container/${action}/${name}`, {
            method: 'POST'
        });
        
        const data = await response.json();
        
        if (data.success) {
            showToast(`Container ${action}ed successfully`, 'success');
            fetchContainers();
        } else {
            showToast(data.error || `Failed to ${action} container`, 'error');
        }
    } catch (error) {
        showToast(`Error: ${error.message}`, 'error');
    }
}

// Delete container
async function deleteContainer(name) {
    if (!confirm(`⚠️ Are you sure you want to delete container "${name}"?\nThis action cannot be undone!`)) {
        return;
    }
    
    try {
        const response = await fetch(`/api/container/delete/${name}`, {
            method: 'POST'
        });
        
        const data = await response.json();
        
        if (data.success) {
            showToast('Container deleted successfully', 'success');
            fetchContainers();
        } else {
            showToast(data.error || 'Failed to delete container', 'error');
        }
    } catch (error) {
        showToast(`Error: ${error.message}`, 'error');
    }
}

// Create container
async function createContainer(event) {
    event.preventDefault();
    
    const containerData = {
        name: document.getElementById('containerName').value,
        image: document.getElementById('containerImage').value,
        cpu: document.getElementById('containerCPU').value,
        memory: document.getElementById('containerMemory').value,
        ports: document.getElementById('containerPorts').value,
        volumes: document.getElementById('containerVolumes').value,
        env: document.getElementById('containerEnv').value
    };
    
    try {
        const response = await fetch('/api/container/create', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(containerData)
        });
        
        const data = await response.json();
        
        if (data.success) {
            showToast('Container created successfully', 'success');
            closeCreateModal();
            fetchContainers();
        } else {
            showToast(data.error || 'Failed to create container', 'error');
        }
    } catch (error) {
        showToast(`Error: ${error.message}`, 'error');
    }
}

// View logs
async function viewLogs(name) {
    try {
        const response = await fetch(`/api/container/logs/${name}?lines=100`);
        const data = await response.json();
        
        document.getElementById('containerLogs').textContent = data.logs || 'No logs available';
        document.getElementById('logsModal').style.display = 'block';
    } catch (error) {
        showToast('Error loading logs', 'error');
    }
}

// Modal functions
function showCreateModal() {
    document.getElementById('createModal').style.display = 'block';
}

function closeCreateModal() {
    document.getElementById('createModal').style.display = 'none';
    document.getElementById('createForm').reset();
}

function closeLogsModal() {
    document.getElementById('logsModal').style.display = 'none';
}

// Auto refresh
function startAutoRefresh() {
    refreshInterval = setInterval(() => {
        countdown--;
        refreshCountdown.textContent = countdown + 's';
        
        if (countdown <= 0) {
            fetchContainers();
            fetchSystemInfo();
            countdown = 5;
        }
    }, 1000);
}

function refreshContainers() {
    fetchContainers();
    fetchSystemInfo();
    countdown = 5;
    refreshCountdown.textContent = '5s';
}

// Toast notifications
function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    
    const icon = {
        success: 'fa-check-circle',
        error: 'fa-exclamation-circle',
        warning: 'fa-exclamation-triangle',
        info: 'fa-info-circle'
    }[type] || 'fa-info-circle';
    
    toast.innerHTML = `
        <i class="fas ${icon}"></i>
        <span>${message}</span>
    `;
    
    const container = document.getElementById('toastContainer');
    container.appendChild(toast);
    
    setTimeout(() => {
        toast.style.animation = 'slideOut 0.3s ease forwards';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// Close modal when clicking outside
window.onclick = function(event) {
    const createModal = document.getElementById('createModal');
    const logsModal = document.getElementById('logsModal');
    
    if (event.target === createModal) {
        closeCreateModal();
    }
    if (event.target === logsModal) {
        closeLogsModal();
    }
}

// Cleanup
window.addEventListener('beforeunload', () => {
    clearInterval(refreshInterval);
});
