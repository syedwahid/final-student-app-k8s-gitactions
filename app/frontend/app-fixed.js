// Configuration - ALWAYS use localhost for port-forward
const API_BASE_URL = 'http://localhost:30001/api';

console.log('🎯 Student Management Frontend - FIXED VERSION');
console.log('🌐 Using API:', API_BASE_URL);

// DOM Elements
const studentTableBody = document.getElementById('student-table-body');
const loadingElement = document.getElementById('loading');
const totalStudentsEl = document.getElementById('total-students');
const gradeAStudentsEl = document.getElementById('grade-a');
const avgAgeEl = document.getElementById('avg-age');

// Demo data as fallback
const DEMO_STUDENTS = [
    { id: 1, name: 'Demo Student 1', age: 20, grade: 'A', email: 'demo1@school.com' },
    { id: 2, name: 'Demo Student 2', age: 21, grade: 'B', email: 'demo2@school.com' },
    { id: 3, name: 'Demo Student 3', age: 22, grade: 'A', email: 'demo3@school.com' }
];

// Initialize
async function init() {
    console.log('Initializing app...');
    showLoading(true);
    
    // Try to load from API
    const apiStudents = await loadFromAPI();
    
    if (apiStudents.length > 0) {
        console.log('Using API data:', apiStudents.length, 'students');
        displayStudents(apiStudents);
    } else {
        console.log('Using demo data');
        displayStudents(DEMO_STUDENTS);
        showMessage('⚠️ Using demo data (backend not connected)', 'warning');
    }
    
    showLoading(false);
}

// Load from API
async function loadFromAPI() {
    try {
        console.log('Fetching from:', API_BASE_URL + '/students');
        const response = await fetch(API_BASE_URL + '/students', {
            timeout: 5000
        });
        
        if (response.ok) {
            return await response.json();
        }
    } catch (error) {
        console.log('API fetch failed:', error.message);
    }
    return [];
}

// Display students in table
function displayStudents(students) {
    studentTableBody.innerHTML = '';
    
    if (students.length === 0) {
        studentTableBody.innerHTML = `
            <tr>
                <td colspan="6" style="text-align: center; padding: 20px; color: #666;">
                    No students to display
                </td>
            </tr>
        `;
        return;
    }
    
    students.forEach(student => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${student.id}</td>
            <td>${student.name}</td>
            <td>${student.age}</td>
            <td><span class="grade-badge grade-${student.grade}">${student.grade}</span></td>
            <td>${student.email}</td>
            <td>
                <div class="action-btns">
                    <button class="action-btn edit-btn">Edit</button>
                    <button class="action-btn delete-btn">Delete</button>
                </div>
            </td>
        `;
        studentTableBody.appendChild(row);
    });
    
    // Update summary
    updateSummary(students);
}

// Update summary cards
function updateSummary(students) {
    const total = students.length;
    const gradeA = students.filter(s => s.grade === 'A').length;
    const totalAge = students.reduce((sum, s) => sum + s.age, 0);
    const avgAge = total > 0 ? Math.round(totalAge / total) : 0;
    
    totalStudentsEl.textContent = total;
    gradeAStudentsEl.textContent = gradeA;
    avgAgeEl.textContent = avgAge;
}

// Show/hide loading
function showLoading(show) {
    if (show) {
        loadingElement.classList.add('show');
    } else {
        loadingElement.classList.remove('show');
    }
}

// Show message
function showMessage(text, type = 'info') {
    const message = document.createElement('div');
    message.className = `message ${type}`;
    message.textContent = text;
    message.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 10px 20px;
        background: ${type === 'warning' ? '#ff9800' : '#4CAF50'};
        color: white;
        border-radius: 5px;
        z-index: 1000;
    `;
    document.body.appendChild(message);
    setTimeout(() => message.remove(), 5000);
}

// Add fetch timeout
if (!window.fetch.timeout) {
    window.fetch.timeout = function(ms) {
        return new Promise((resolve, reject) => {
            const timer = setTimeout(() => reject(new Error('Timeout')), ms);
            fetch.then(response => {
                clearTimeout(timer);
                resolve(response);
            }).catch(reject);
        });
    };
}

// Initialize when page loads
document.addEventListener('DOMContentLoaded', init);
