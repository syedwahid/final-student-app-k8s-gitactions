const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 3000;

console.log('🚀 Student Backend with FULL CRUD Starting...');

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

// 1. Health check
app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'OK', 
        message: 'Backend with FULL CRUD is working!',
        timestamp: new Date().toISOString(),
        studentCount: students.length
    });
});

// 2. GET all students
app.get('/api/students', (req, res) => {
    console.log('GET /api/students - returning', students.length, 'students');
    res.json(students);
});

// 3. GET single student by ID
app.get('/api/students/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const student = students.find(s => s.id === id);
    
    if (!student) {
        return res.status(404).json({ error: 'Student not found' });
    }
    
    res.json(student);
});

// 4. POST create new student (FRONTEND USES THIS)
app.post('/api/students', (req, res) => {
    const { name, age, grade, email } = req.body;
    
    // Validation
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
    console.log('POST /api/students - created:', newStudent);
    
    res.status(201).json({
        message: 'Student created successfully',
        student: newStudent
    });
});

// 5. PUT update student (FRONTEND USES THIS)
app.put('/api/students/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const { name, age, grade, email } = req.body;
    
    // Validation
    if (!name || !age || !grade || !email) {
        return res.status(400).json({ error: 'All fields are required' });
    }
    
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
    console.log('PUT /api/students/' + id + ' - updated:', updatedStudent);
    
    res.json({
        message: 'Student updated successfully',
        student: updatedStudent
    });
});

// 6. DELETE student (FRONTEND USES THIS)
app.delete('/api/students/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const studentIndex = students.findIndex(s => s.id === id);
    
    if (studentIndex === -1) {
        return res.status(404).json({ error: 'Student not found' });
    }
    
    const deletedStudent = students.splice(studentIndex, 1)[0];
    console.log('DELETE /api/students/' + id + ' - deleted:', deletedStudent);
    
    res.json({
        message: 'Student deleted successfully',
        student: deletedStudent
    });
});

// 7. Search students
app.get('/api/students/search/:query', (req, res) => {
    const query = req.params.query.toLowerCase();
    const results = students.filter(s => 
        s.name.toLowerCase().includes(query) ||
        s.email.toLowerCase().includes(query) ||
        s.grade.toLowerCase().includes(query)
    );
    res.json(results);
});

// 8. 404 handler for undefined routes
app.use((req, res) => {
    console.log('404 for:', req.method, req.path);
    res.status(404).json({ 
        error: 'Endpoint not found',
        message: `Route ${req.method} ${req.path} does not exist`
    });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`✅ Backend with FULL CRUD running on port ${PORT}`);
    console.log(`✅ Available endpoints:`);
    console.log(`   GET    /api/health`);
    console.log(`   GET    /api/students`);
    console.log(`   GET    /api/students/:id`);
    console.log(`   POST   /api/students`);
    console.log(`   PUT    /api/students/:id`);
    console.log(`   DELETE /api/students/:id`);
    console.log(`   GET    /api/students/search/:query`);
    console.log(`✅ Total students loaded: ${students.length}`);
});
