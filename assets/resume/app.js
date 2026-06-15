// 1. 声明硬化的简历数据对象（数据有状态）
const resumeData = {
    name: "WY (weiyang)",
    role: "Full-Stack Devops Architecture Warrior",
    login42: "weiyang",
    cluster: "Inception Six-Star Network Edition",
    skills: ["Docker", "Docker-Compose", "Nginx", "MariaDB", "Redis", "Adminer", "vsftpd", "Pure JavaScript"],
    timestamp: new Date().toLocaleString()
};

// 2. 原生 JavaScript DOM 动态动态自举流
function renderResume() {
    const container = document.getElementById('resume-container');
    
    const htmlPayload = `
        <h1>${resumeData.name}</h1>
        <p style="color: #94a3b8; font-style: italic;">${resumeData.role}</p>
        <hr style="border-color: #334155;">
        <p><strong>42 Login:</strong> <span style="color: #fbbf24;">${resumeData.login42}</span></p>
        <p><strong>Infrastructure Cluster:</strong> ${resumeData.cluster}</p>
        <div>
            <strong>Core Stack Matrix:</strong><br>
            ${resumeData.skills.map(skill => `<span class="skill-tag">${skill}</span>`).join('')}
        </div>
        <div id="timestamp">Engine rendered at: ${resumeData.timestamp} (Homogeneous Linux Env)</div>
    `;
    
    // 原子化塞入浏览器視界
    container.innerHTML = htmlPayload;
}

// 3. 监听生命周期加载，瞬间引爆渲染
document.addEventListener('DOMContentLoaded', renderResume);
