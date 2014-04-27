# a sample data entry:
# {
#   "Milliseconds":"518",
#   "Accelerometer X":"-2.75",
#   "Accelerometer Y":"0.51",
#   "Accelerometer Z":"10.16",
#   "Magnetic X":"12.36",
#   "Magnetic Y":"19.55",
#   "Magnetic Z":"-37.86",
#   "Gyroscope X":"-0.06",
#   "Gyroscope Y":"0.07",
#   "Gyroscope Z":"0.07",
#   "Pressure":"1012.20",
#   "Temperature":"22.64"
# }

fs      = require 'fs'
net     = require 'net'

lazy    = require 'lazy'

lineNumber = 0
socket = net.connect {port: 2003}
yesterday = new Date()
yesterday.setDate(yesterday.getDate() - 1)
yesterday = yesterday / 1000

socket.on 'connect', ->
  new lazy(fs.createReadStream('./DATALOG.TXT'))
          .lines
          .forEach (line) ->
            lineNumber++
            return if lineNumber is 1
            dataEntry = JSON.parse line.toString()
            dataEntryTimestamp = yesterday + dataEntry['Milliseconds'] / 1000
            for metric, value of dataEntry
              if metric isnt 'Milliseconds'
                dataMessage = "event.0.#{metric.replace(' ', '_')} #{value} #{dataEntryTimestamp}\n"
                console.log lineNumber
                socket.write dataMessage
            socket.end() if lineNumber is 28003

socket.on 'data', (data) ->
  console.log "DATA RECEIVED: #{data.toString()}"

socket.on 'error', (error) ->
  console.log "ERROR: #{error}"
