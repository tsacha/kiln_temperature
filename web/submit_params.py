import json
import os
def application(env, start_response):
  try:
    request_body_size = int(env.get('CONTENT_LENGTH', 0))
  except (ValueError):
    request_body_size = 0    
  request_body = env['wsgi.input'].read(request_body_size)
  data = json.loads(request_body.decode('utf8'))
  for sonde in data.keys():
    for key in data[sonde].keys():
      data[sonde][key] = str(int(data[sonde][key]))
  with open('params.txt','w') as out:
    line1 = "cropH="+data["haut"]["width"]+"x"+data["haut"]["height"]+"+"+data["haut"]["x"]+"+"+data["haut"]["y"]
    line2 = "cropV="+data["bas"]["width"]+"x"+data["bas"]["height"]+"+"+data["bas"]["x"]+"+"+data["bas"]["y"]
    line3 = "threshold="+data["global"]["threshold"]
    line4 = "shear="+data["global"]["shear_h"]+","+data["global"]["shear_v"]
    out.write('{}\n{}\n{}\n{}\n'.format(line1,line2,line3,line4))
  with open("params.json",'w') as out:
    out.write(json.dumps(data))
  start_response('200 OK', [('Content-Type','text/html')])  
  return [b"OK"]

