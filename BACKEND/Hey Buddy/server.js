import express from "express";
import mongoose from "mongoose";
import cors from "cors";

const app = express();
app.use(express.json());
app.use(cors());

mongoose.connect("mongodb://127.0.0.1:27017/heyybuddy", {
    useNewUrlParser: true,
    useUnifiedTopology: true,
});

const workoutSchema = new mongoose.Schema({
    workoutType: String,
    date: { type: Date, default: Date.now },
});

const Workout = mongoose.model("Workout", workoutSchema);

app.post("/api/workouts", async (req, res) => {
    try {
        const { workoutType } = req.body;
        console.log(workoutType);

        const workout = new Workout({ workoutType });
        await workout.save();

        res.json({ success: true, message: "Workout saved", workout });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.get("/api/workouts", async (req, res) => {
    try {
        const workouts = await Workout.find().sort({ date: -1 });

        let streak = 0;
        let lastDate = null;

        for (let workout of workouts) {
            const workoutDate = new Date(workout.date);
            workoutDate.setHours(0, 0, 0, 0);

            if (lastDate === null) {
                streak = 1;
            } else {
                const diffDays = (lastDate - workoutDate) / 86400000;

                if (diffDays === 0) {
                    continue;
                } else if (diffDays === 1) {
                    streak++;
                } else {
                    break;
                }
            }

            lastDate = workoutDate;
        }

        res.json({ streak, workouts });
        console.log("Workouts get request received");
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

const PORT = 5000;
app.listen(PORT, "0.0.0.0", () =>
    console.log(`🚀 Server running on http://localhost:${PORT}`)
);
