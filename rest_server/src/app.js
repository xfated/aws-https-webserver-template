const express = require('express')
const cors = require("cors")
const app = express()
const port = 3000

// Enable cors to make requests from a public client
app.use(cors())

app.get('/', (req, res) => {
  res.send('Hello World!')
})

// Create a healthcheck endpoint for load balancer to register your service
app.get('/healthcheck', (req, res) => {
  res.status(200);
  res.send('Healthcheck OK')
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})