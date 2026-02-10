import { useState, useEffect } from 'react'
import './App.css'

interface ServerData {
  hostname: string;
  server_time: string;
  message: string;
}

function App() {
  const [data, setData] = useState<ServerData | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        // CORRECCIÓN: Usamos window.location.hostname para obtener la IP real del servidor
        const apiUrl = `http://${window.location.hostname}:8080/api/status`;
        
        const res = await fetch(apiUrl);
        const json = await res.json();
        setData(json);
      } catch (e) {
        console.error("Error conectando al backend:", e);
      }
    };
    fetchData();
    const interval = setInterval(fetchData, 2000); // Polling cada 2 seg
    return () => clearInterval(interval);
  }, []);

  return (
    <div style={{ backgroundColor: '#282c34', color: 'white', height: '100vh', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', fontFamily: 'monospace' }}>
      <h1>☁️ Cloud Pulse</h1>
      {data ? (
        <div style={{ border: '2px solid #4caf50', padding: '20px', borderRadius: '10px', textAlign: 'left', minWidth: '300px' }}>
          <p><strong>Status:</strong> <span style={{color: '#4caf50'}}>● ONLINE</span></p>
          <p><strong>Host:</strong> {data.hostname}</p>
          <p><strong>Time:</strong> {data.server_time}</p>
          <hr style={{borderColor: '#444'}}/>
          <p style={{textAlign: 'center', color: '#ffd700'}}>"{data.message}"</p>
        </div>
      ) : (
        <div style={{textAlign: 'center'}}>
           <p>Connecting to Backend...</p>
           <small style={{color: '#aaa'}}>Target: {window.location.hostname}:8080</small>
        </div>
      )}
    </div>
  )
}

export default App