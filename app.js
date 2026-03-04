import React, { useState } from "react";
import axios from "axios";

function App() {
  const [username, setUsername] = useState("");
  const [score, setScore] = useState("");

  const submit = async () => {
    await axios.post("/api/submit", { username, score: parseInt(score) });
    alert("Submitted!");
  };

  return (
    <div>
      <h1>Leaderboard</h1>
      <input placeholder="Name" onChange={e => setUsername(e.target.value)} />
      <input placeholder="Score" onChange={e => setScore(e.target.value)} />
      <button onClick={submit}>Submit</button>
    </div>
  );
}

export default App;
