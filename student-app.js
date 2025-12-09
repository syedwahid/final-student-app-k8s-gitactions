const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 9393;

console.log('🚀 Student Management System - Single Container Version');

// Middleware
app.use(cors());
app.use(express.json());

// In-memory storage
let students = [
    { id: 1, name: 'John Doe', age: 20, grade: 'A', email: 'john@school.com' },
    { id: 2, name: 'Jane Smith', age: 21, grade: 'B', email: 'jane@school.com' },
    { id: 3, name: 'Mike Johnson', age: 19, grade: 'A', email: 'mike@school.com' },
    { id: 4, name: 'Sarah Wilson', age: 22, grade: 'C', email: 'sarah@school.com' },
    { id: 5, name: 'Tom Brown', age: 18, grade: 'B', email: 'tom@school.com' }
];

let nextId = 6;

// API Endpoints
app.get('/api/health', (req, res) => {
    res.json({
        status: 'OK',
        message: 'Student Management Backend is running',
        timestamp: new Date().toISOString(),
        studentCount: students.length
    });
});

app.get('/api/students', (req, res) => {
    res.json(students);
});

app.get('/api/students/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const student = students.find(s => s.id === id);
    if (!student) return res.status(404).json({ error: 'Student not found' });
    res.json(student);
});

app.post('/api/students', (req, res) => {
    const { name, age, grade, email } = req.body;
    
    if (!name || !age || !grade || !email) {
        return res.status(400).json({ error: 'All fields are required' });
    }
    
    const newStudent = {
        id: nextId++,
        name: name.trim(),
        age: parseInt(age),
        grade: grade.toUpperCase(),
        email: email.trim()
    };
    
    students.push(newStudent);
    res.status(201).json({
        message: 'Student created successfully',
        student: newStudent
    });
});

app.put('/api/students/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const { name, age, grade, email } = req.body;
    
    const studentIndex = students.findIndex(s => s.id === id);
    if (studentIndex === -1) {
        return res.status(404).json({ error: 'Student not found' });
    }
    
    const updatedStudent = {
        id,
        name: name.trim(),
        age: parseInt(age),
        grade: grade.toUpperCase(),
        email: email.trim()
    };
    
    students[studentIndex] = updatedStudent;
    res.json({
        message: 'Student updated successfully',
        student: updatedStudent
    });
});

app.delete('/api/students/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const studentIndex = students.findIndex(s => s.id === id);
    
    if (studentIndex === -1) {
        return res.status(404).json({ error: 'Student not found' });
    }
    
    const deletedStudent = students.splice(studentIndex, 1)[0];
    res.json({
        message: 'Student deleted successfully',
        student: deletedStudent
    });
});

app.get('/api/students/search/:query', (req, res) => {
    const query = req.params.query.toLowerCase();
    const results = students.filter(s => 
        s.name.toLowerCase().includes(query) ||
        s.email.toLowerCase().includes(query) ||
        s.grade.toLowerCase().includes(query)
    );
    res.json(results);
});

// HTML template as a regular string
const htmlTemplate = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Management System - Single Container Version</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; padding: 20px; }
        .container { max-width: 1200px; margin: 0 auto; background: white; border-radius: 20px; box-shadow: 0 20px 60px rgba(0,0,0,0.3); overflow: hidden; }
        header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px 40px; }
        .header-content { display: flex; justify-content: space-between; align-items: center; }
        h1 { font-size: 2.5rem; margin-bottom: 10px; }
        .subtitle { opacity: 0.9; font-size: 1.1rem; }
        .version-badge { background: rgba(255,255,255,0.2); padding: 8px 16px; border-radius: 20px; font-size: 0.9rem; font-weight: 500; }
        .controls { padding: 30px 40px; background: #f8fafc; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; gap: 20px; }
        .search-box { flex: 1; max-width: 400px; }
        .search-box input { width: 100%; padding: 12px 20px; border: 2px solid #e2e8f0; border-radius: 10px; font-size: 1rem; }
        .search-box input:focus { outline: none; border-color: #667eea; box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1); }
        .btn-primary { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; padding: 12px 30px; border-radius: 10px; font-size: 1rem; font-weight: 600; cursor: pointer; }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3); }
        .summary-cards { padding: 30px 40px; display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; }
        .card { background: white; padding: 25px; border-radius: 15px; border: 1px solid #e2e8f0; text-align: center; }
        .card:hover { transform: translateY(-5px); box-shadow: 0 10px 25px rgba(0,0,0,0.1); }
        .card h3 { color: #64748b; font-size: 0.9rem; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 10px; }
        .card .value { font-size: 2.5rem; font-weight: 700; color: #1e293b; margin-bottom: 10px; }
        .table-container { padding: 0 40px 40px; overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; background: white; border-radius: 15px; overflow: hidden; box-shadow: 0 5px 15px rgba(0,0,0,0.05); }
        thead { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; }
        th { padding: 20px; text-align: left; font-weight: 600; }
        tbody tr { border-bottom: 1px solid #e2e8f0; }
        tbody tr:hover { background: #f8fafc; }
        td { padding: 20px; color: #1e293b; }
        .grade-badge { padding: 6px 15px; border-radius: 20px; font-size: 0.9rem; font-weight: 600; display: inline-block; }
        .grade-A { background: #dcfce7; color: #166534; }
        .grade-B { background: #fef3c7; color: #92400e; }
        .grade-C { background: #fee2e2; color: #991b1b; }
        .grade-D { background: #e0e7ff; color: #3730a3; }
        .grade-F { background: #f3f4f6; color: #374151; }
        .action-btns { display: flex; gap: 10px; }
        .btn-edit { background: #dbeafe; color: #1d4ed8; padding: 8px 15px; border-radius: 8px; border: none; cursor: pointer; }
        .btn-delete { background: #fee2e2; color: #dc2626; padding: 8px 15px; border-radius: 8px; border: none; cursor: pointer; }
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); justify-content: center; align-items: center; z-index: 1000; }
        .modal.show { display: flex; }
        .modal-content { background: white; border-radius: 20px; padding: 40px; width: 90%; max-width: 500px; }
        .form-group { margin-bottom: 20px; }
        .form-group input, .form-group select { width: 100%; padding: 12px 16px; border: 2px solid #e2e8f0; border-radius: 10px; font-size: 1rem; }
        .form-actions { display: flex; gap: 15px; margin-top: 30px; }
        .btn-secondary { background: #f1f5f9; color: #475569; border: none; padding: 12px; border-radius: 10px; cursor: pointer; }
        .toast { position: fixed; bottom: 30px; right: 30px; padding: 15px 25px; background: #10b981; color: white; border-radius: 10px; transform: translateY(100px); opacity: 0; transition: all 0.3s; }
        .toast.show { transform: translateY(0); opacity: 1; }
        .toast.error { background: #ef4444; }
        .loading { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(255,255,255,0.9); justify-content: center; align-items: center; z-index: 1002; }
        .loading.show { display: flex; }
        .spinner { width: 50px; height: 50px; border: 3px solid #e2e8f0; border-top: 3px solid #667eea; border-radius: 50%; animation: spin 1s linear infinite; margin-bottom: 20px; }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        @media (max-width: 768px) { .container { margin: 10px; } .controls { flex-direction: column; } .summary-cards { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="header-content">
                <div>
                    <h1>Student Management System</h1>
                    <p class="subtitle">Single Container Version • In-Memory Storage</p>
                </div>
                <div class="version-badge">v1.0 • All-in-One</div>
            </div>
        </header>

        <div class="controls">
            <div class="search-box">
                <input type="text" id="search" placeholder="Search students by name, email, or grade...">
            </div>
            <button class="btn-primary" id="add-btn">Add New Student</button>
        </div>

        <div class="summary-cards">
            <div class="card">
                <h3>Total Students</h3>
                <div class="value" id="total-students">0</div>
            </div>
            <div class="card">
                <h3>Grade A Students</h3>
                <div class="value" id="grade-a">0</div>
            </div>
            <div class="card">
                <h3>Average Age</h3>
                <div class="value" id="avg-age">0</div>
            </div>
        </div>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>NAME</th>
                        <th>AGE</th>
                        <th>GRADE</th>
                        <th>EMAIL</th>
                        <th>ACTIONS</th>
                    </tr>
                </thead>
                <tbody id="students-table"></tbody>
            </table>
        </div>
    </div>

    <div class="modal" id="student-modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 id="modal-title">Add New Student</h2>
                <p>Fill in the student details below</p>
            </div>
            <form id="student-form">
                <input type="hidden" id="student-id">
                <div class="form-group">
                    <label for="name">Full Name</label>
                    <input type="text" id="name" placeholder="Enter student's full name" required>
                </div>
                <div class="form-group">
                    <label for="age">Age</label>
                    <input type="number" id="age" min="16" max="30" placeholder="Enter age (16-30)" required>
                </div>
                <div class="form-group">
                    <label for="grade">Grade</label>
                    <select id="grade" required>
                        <option value="">Select grade</option>
                        <option value="A">A - Excellent</option>
                        <option value="B">B - Good</option>
                        <option value="C">C - Average</option>
                        <option value="D">D - Below Average</option>
                        <option value="F">F - Failed</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" placeholder="Enter student email" required>
                </div>
                <div class="form-actions">
                    <button type="button" class="btn-secondary" id="cancel-btn">Cancel</button>
                    <button type="submit" class="btn-primary">Save Student</button>
                </div>
            </form>
        </div>
    </div>

    <div class="modal" id="delete-modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Confirm Delete</h2>
                <p id="delete-message">Are you sure you want to delete this student?</p>
            </div>
            <div class="form-actions">
                <button type="button" class="btn-secondary" id="cancel-delete">Cancel</button>
                    <button type="button" class="btn-primary" id="confirm-delete" style="background: #ef4444;">Delete</button>
            </div>
        </div>
    </div>

    <div class="toast" id="toast"></div>
    <div class="loading" id="loading">
        <div class="spinner"></div>
        <p>Loading students...</p>
    </div>

    <script>
        let students = [], currentStudentId = null, isEditing = false;
        const API_BASE = '/api';
        
        document.addEventListener('DOMContentLoaded', () => {
            document.getElementById('add-btn').addEventListener('click', () => openModal(false));
            document.getElementById('cancel-btn').addEventListener('click', closeModal);
            document.getElementById('cancel-delete').addEventListener('click', closeDeleteModal);
            document.getElementById('confirm-delete').addEventListener('click', deleteStudent);
            document.getElementById('student-form').addEventListener('submit', saveStudent);
            document.getElementById('search').addEventListener('input', filterStudents);
            loadStudents();
        });
        
        async function loadStudents() {
            showLoading(true);
            try {
                const response = await fetch(API_BASE + '/students');
                students = await response.json();
                renderStudents();
                updateSummary();
            } catch {
                showToast('Failed to load students', true);
                students = [];
                renderStudents();
                updateSummary();
            } finally {
                showLoading(false);
            }
        }
        
        function renderStudents(studentsToRender = students) {
            const table = document.getElementById('students-table');
            table.innerHTML = studentsToRender.length ? studentsToRender.map(s => {
                return \`
                <tr>
                    <td>\${s.id}</td>
                    <td>\${s.name}</td>
                    <td>\${s.age}</td>
                    <td><span class="grade-badge grade-\${s.grade}">\${s.grade}</span></td>
                    <td>\${s.email}</td>
                    <td>
                        <div class="action-btns">
                            <button class="btn-edit" onclick="editStudent(\${s.id})">Edit</button>
                            <button class="btn-delete" onclick="confirmDelete(\${s.id})">Delete</button>
                        </div>
                    </td>
                </tr>
                \`;
            }).join('') : '<tr><td colspan="6" style="text-align:center;padding:40px;">No students found</td></tr>';
        }
        
        function updateSummary() {
            const total = students.length;
            const gradeA = students.filter(s => s.grade === 'A').length;
            const totalAge = students.reduce((sum, s) => sum + s.age, 0);
            const avgAge = total > 0 ? Math.round(totalAge / total) : 0;
            document.getElementById('total-students').textContent = total;
            document.getElementById('grade-a').textContent = gradeA;
            document.getElementById('avg-age').textContent = avgAge;
        }
        
        function filterStudents() {
            const term = document.getElementById('search').value.toLowerCase();
            const filtered = students.filter(s => 
                s.name.toLowerCase().includes(term) || 
                s.email.toLowerCase().includes(term) || 
                s.grade.toLowerCase().includes(term)
            );
            renderStudents(filtered);
        }
        
        function openModal(editing = false, student = null) {
            isEditing = editing;
            document.getElementById('modal-title').textContent = editing ? 'Edit Student' : 'Add New Student';
            if (editing && student) {
                document.getElementById('student-id').value = student.id;
                document.getElementById('name').value = student.name;
                document.getElementById('age').value = student.age;
                document.getElementById('grade').value = student.grade;
                document.getElementById('email').value = student.email;
            } else {
                document.getElementById('student-form').reset();
                document.getElementById('student-id').value = '';
            }
            document.getElementById('student-modal').classList.add('show');
        }
        
        function closeModal() { 
            document.getElementById('student-modal').classList.remove('show'); 
        }
        
        window.editStudent = function(id) { 
            const student = students.find(s => s.id === id); 
            if (student) openModal(true, student); 
        };
        
        window.confirmDelete = function(id) {
            currentStudentId = id;
            const student = students.find(s => s.id === id);
            if (student) {
                document.getElementById('delete-message').textContent = 
                    'Are you sure you want to delete "' + student.name + '"?';
            }
            document.getElementById('delete-modal').classList.add('show');
        };
        
        function closeDeleteModal() { 
            document.getElementById('delete-modal').classList.remove('show'); 
            currentStudentId = null; 
        }
        
        async function deleteStudent() {
            try {
                const response = await fetch(API_BASE + '/students/' + currentStudentId, { 
                    method: 'DELETE' 
                });
                showToast('Student deleted successfully');
                await loadStudents();
                closeDeleteModal();
            } catch { 
                showToast('Failed to delete student', true); 
            }
        }
        
        async function saveStudent(e) {
            e.preventDefault();
            const studentData = {
                name: document.getElementById('name').value.trim(),
                age: parseInt(document.getElementById('age').value),
                grade: document.getElementById('grade').value,
                email: document.getElementById('email').value.trim()
            };
            
            if (!studentData.name || !studentData.age || !studentData.grade || !studentData.email) {
                showToast('Please fill in all fields', true);
                return;
            }
            
            try {
                const studentId = document.getElementById('student-id').value;
                const url = studentId ? API_BASE + '/students/' + studentId : API_BASE + '/students';
                const method = studentId ? 'PUT' : 'POST';
                
                const response = await fetch(url, {
                    method: method,
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(studentData)
                });
                showToast('Student saved successfully');
                await loadStudents();
                closeModal();
            } catch { 
                showToast('Failed to save student', true); 
            }
        }
        
        function showToast(message, isError = false) {
            const toast = document.getElementById('toast');
            toast.textContent = message;
            toast.className = 'toast' + (isError ? ' error' : '');
            toast.classList.add('show');
            setTimeout(() => toast.classList.remove('show'), 3000);
        }
        
        function showLoading(show) {
            document.getElementById('loading').classList.toggle('show', show);
        }
    </script>
</body>
</html>
`;

// Serve the HTML page
app.get('/', (req, res) => {
    res.send(htmlTemplate);
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`✅ Server running on port ${PORT}`);
    console.log(`✅ Frontend: http://localhost:${PORT}`);
    console.log(`✅ API: http://localhost:${PORT}/api/health`);
    console.log(`📊 Initial students: ${students.length}`);
});
