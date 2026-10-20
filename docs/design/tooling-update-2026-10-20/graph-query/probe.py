import pathlib,json,subprocess,threading,queue,time,os
root=pathlib.Path.cwd().resolve();out=root/'docs/design/tooling-update-2026-10-20/graph-query'
plugins=json.loads(subprocess.check_output(['C:/Users/zalub/.local/bin/claude.exe','plugin','list','--json'],text=True,encoding='utf-8'))
plugin=next(p for p in plugins if p['id'].startswith('graph-query-mcp@'))
cmd=['C:/Users/zalub/.local/bin/fastmcp.exe','run',str(pathlib.Path(plugin['installPath'])/'server.py')]
env=os.environ.copy();env['GRAPH_JSON_PATH']=str(root/'graphify-out/graph.json');env['SECONDARY_GRAPH_JSON_PATH']=str(root/'graphify-out/secondary-graph.json')
p=subprocess.Popen(cmd,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,encoding='utf-8',bufsize=1,env=env)
q=queue.Queue();errors=[];records=[]
def reader():
 for line in p.stdout:
  try:q.put(json.loads(line))
  except:records.append({'stdout_non_json':line})
def stderr():
 for line in p.stderr:errors.append(line)
threading.Thread(target=reader,daemon=True).start();threading.Thread(target=stderr,daemon=True).start()
def send(x):p.stdin.write(json.dumps(x)+'\n');p.stdin.flush()
def request(i,m,params):
 send({'jsonrpc':'2.0','id':i,'method':m,'params':params});end=time.time()+20
 while time.time()<end:
  try:r=q.get(timeout=.2)
  except queue.Empty:
   if p.poll() is not None:raise RuntimeError('Exited '+str(p.poll()))
   continue
  records.append(r)
  if r.get('id')==i:return r
 raise RuntimeError('Timeout '+m)
r={}
try:
 r['initialize']=request(1,'initialize',{'protocolVersion':'2025-03-26','capabilities':{},'clientInfo':{'name':'culmina-graph-health','version':'1'}})
 send({'jsonrpc':'2.0','method':'notifications/initialized'})
 r['tools']=request(2,'tools/list',{})
 r['no_graph_response']=request(3,'tools/call',{'name':'search_nodes','arguments':{'query':'Culmina','scope':'personal','limit':1}})
 print(json.dumps({'server':r['initialize'].get('result',{}).get('serverInfo'),'tools':[t['name'] for t in r['tools'].get('result',{}).get('tools',[])],'response':r['no_graph_response']},ensure_ascii=True))
except Exception as e:r['error']=str(e);print(str(e))
finally:
 try:p.stdin.close();p.wait(timeout=10)
 except:subprocess.run(['taskkill','/PID',str(p.pid),'/T','/F'],capture_output=True)
 r['stderr']=''.join(errors);r['exit_code']=p.poll();r['protocol']=records
 (out/'health.json').write_text(json.dumps(r,indent=2),encoding='utf-8')
