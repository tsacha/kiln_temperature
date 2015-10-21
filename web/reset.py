import json
import os
def application(env, start_response):
  try:
    request_body_size = int(env.get('CONTENT_LENGTH', 0))
  except (ValueError):
    request_body_size = 0    
  request_body = env['wsgi.input'].read(request_body_size)
  data = request_body.decode('utf8')
  if data == "reset:true":
    os.system("/usr/share/nginx/html/reset.sh")
  start_response('200 OK', [('Content-Type','text/html')])  
  return [b"OK"]

