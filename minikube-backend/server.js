const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 3000;

console.log('🚀 Minikube Backend Starting...');

app.use(cors());
app.use(express.json());

const students = [
    { id: 1, name: 'Minikube Student 1', age: 20, grade: 'A', email: 'student1@school.com' },
    { id: 2, name: 'Minikube Student 2', age: 21, grade: 'B', email: 'student2@school.com' },
    { id: 3, name: 'Minikube Student 3', age: 22, grade: 'A', email: 'student3@school.com' },
    { id: 4, name: 'Minikube Student 4', age: 23, grade: 'C', email: 'student4@school.com' },
    { id: 5, name: 'Minikube Student 5', age: 19, grade: 'B', email: 'student5@school.com' }
];

// Health endpoint
app.get('/api/health', (req, res) => {
    res.json({
        status: 'OK',
        message: 'Minikube Backend is running!',
        timestamp: new Date().toISOString(),
        studentCount: students.length
    });
});

// Get all students
app.get('/api/students', (req, res) => {
    console.log('Sending', students.length, 'students');
    res.json(students);
});

// Get student by ID
app.get('/api/students/:id', (req, res) => {
    const student = students.find(s => s.id === parseInt(req.params.id));
    if (student) {
        res.json(student);
    } else {
        res.status(404).json({ error: 'Student not found' });
    }
});

// Create student
app.post('/api/students', (req, res) => {
    const newStudent = {
        id: students.length + 1,
        ...req.body
    };
    students.push(newStudent);
    res.status(201).json(newStudent);
});

// Update student
app.put('/api/students/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const index = students.findIndex(s => s.id === id);
    if (index !== -1) {
        students[index] = { id, ...req.body };
        res.json(students[index]);
    } else {
        res.status(404).json({ error: 'Student not found' });
    }
});

// Delete student
app.delete('/api/students/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const index = students.findIndex(s => s.id === id);
    if (index !== -1) {
        students.splice(index, 1);
        res.json({ message: 'Student deleted' });
    } else {
        res.status(404).json({ error: 'Student not found' });
    }
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`✅ Minikube Backend running on port ${PORT}`);
    console.log(`✅ Health: http://localhost:${PORT}/api/health`);
    console.log(`✅ Students: http://localhost:${PORT}/api/students`);
});
