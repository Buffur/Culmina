import subprocess,threading,queue,json,time,os,pathlib
root=pathlib.Path.cwd().resolve();out=root/'docs/design/tooling-update-2026-10-20/dart'
env=os.environ.copy();env['PATH']='C:/flutter/bin;'+env['PATH']
cmd=['C:/Users/zalub/.codex/tools/dart-mcp-dart-3.13.3-data/install/app-bundles/dart_mcp_server/hosted/1.2.1/bundle/bin/dart_mcp_server.exe','--dart-sdk','C:/flutter/bin/cache/dart-sdk','--flutter-sdk','C:/flutter']
p=subprocess.Popen(cmd,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,encoding='utf-8',bufsize=1,env=env)
q=queue.Queue();errs=[];records=[]
def reader():
 for line in p.stdout:
  try:q.put(json.loads(line))
  except:records.append({'stdout_non_json':line})
def stderr():
 for line in p.stderr:errs.append(line)
threading.Thread(target=reader,daemon=True).start();threading.Thread(target=stderr,daemon=True).start()
def send(d):p.stdin.write(json.dumps(d)+'\n');p.stdin.flush()
def request(i,method,params,timeout=60):
 send({'jsonrpc':'2.0','id':i,'method':method,'params':params});end=time.time()+timeout
 while time.time()<end:
  try:r=q.get(timeout=.2)
  except queue.Empty:
   if p.poll() is not None:raise RuntimeError('Process exited '+str(p.poll()))
   continue
  records.append(r)
  if r.get('method')=='roots/list':
   send({'jsonrpc':'2.0','id':r['id'],'result':{'roots':[{'uri':(root/'lib').as_uri()+'/','name':'Culmina'}]}})
  if r.get('id')==i and 'method' not in r:return r
 raise RuntimeError('Timed out '+method)
results={}
try:
 results['initialize']=request(1,'initialize',{'protocolVersion':'2025-03-26','capabilities':{'roots':{'listChanged':True}},'clientInfo':{'name':'culmina-dart-mcp-health','version':'1'}},20)
 send({'jsonrpc':'2.0','method':'notifications/initialized'})
 results['tools']=request(2,'tools/list',{},20)
 tools={t['name']:t for t in results['tools'].get('result',{}).get('tools',[])}
 (out/'tools-schemas.json').write_text(json.dumps(tools,indent=2),encoding='utf-8')
 results['roots']=request(3,'tools/call',{'name':'roots','arguments':{'command':'add','uris':[(root/'lib').as_uri()+'/']}},20)
 results['runtime_discovery']=request(5,'tools/call',{'name':'dtd','arguments':{'command':'listDtdUris'}},20)
 results['connected_apps']=request(6,'tools/call',{'name':'dtd','arguments':{'command':'listConnectedApps'}},20)
 results['analysis']=request(4,'tools/call',{'name':'analyze_files','arguments':{'roots':[{'root':(root/'lib').as_uri()+'/','paths':['main.dart']}],'applyFixes':False}},60)
 results['runtime_discovery']=request(5,'tools/call',{'name':'dtd','arguments':{'command':'listDtdUris'}},20)
 results['connected_apps']=request(6,'tools/call',{'name':'dtd','arguments':{'command':'listConnectedApps'}},20)
 print(json.dumps({'pid':p.pid,'serverInfo':results['initialize'].get('result',{}).get('serverInfo'),'tools':list(tools)}))
except Exception as e:results['error']=str(e);print(str(e))
finally:
 try:p.stdin.close();p.wait(timeout=10)
 except:subprocess.run(['taskkill','/PID',str(p.pid),'/T','/F'],capture_output=True)
 results['stderr']=''.join(errs);results['protocol']=records;results['exit_code']=p.poll()
 (out/'health.json').write_text(json.dumps(results,indent=2),encoding='utf-8')
