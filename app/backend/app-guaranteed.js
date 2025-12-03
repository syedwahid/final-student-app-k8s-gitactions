console.log("🚀 GUARANTEED BACKEND STARTING");
const express = require("express");
const cors = require("cors");
const app = express();
app.use(cors());
app.use(express.json());

const students = [
    {id:1,name:"GUARANTEED Student 1",age:20,grade:"A",email:"student1@school.com"},
    {id:2,name:"GUARANTEED Student 2",age:21,grade:"B",email:"student2@school.com"},
    {id:3,name:"GUARANTEED Student 3",age:22,grade:"A",email:"student3@school.com"},
    {id:4,name:"GUARANTEED Student 4",age:23,grade:"C",email:"student4@school.com"},
    {id:5,name:"GUARANTEED Student 5",age:19,grade:"B",email:"student5@school.com"}
];

app.get("/api/health", (req, res) => {
    console.log("Health check");
    res.json({status:"OK",message:"GUARANTEED Backend",students:students.length});
});

app.get("/api/students", (req, res) => {
    console.log("Returning", students.length, "students");
    res.json(students);
});

app.listen(3000, "0.0.0.0", () => {
    console.log("✅ GUARANTEED Backend running on 3000");
});
