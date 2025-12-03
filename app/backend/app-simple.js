const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 3000;

console.log('🚀 SIMPLE Backend Starting...');

app.use(cors());
app.use(express.json());

const students = [
    { id: 1, name: 'Alice Johnson', age: 20, grade: 'A', email: 'alice@school.com' },
    { id: 2, name: 'Bob Smith', age: 21, grade: 'B', email: 'bob@school.com' },
    { id: 3, name: 'Charlie Brown', age: 22, grade: 'A', email: 'charlie@school.com' }
];

app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'OK', 
        message: 'SIMPLE Backend is working!',
        students: students.length 
    });
});

app.get('/api/students', (req, res) => {
    console.log('GET /api/students - returning', students.length, 'students');
    res.json(students);
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`✅ SIMPLE Backend on port ${PORT}`);
});
