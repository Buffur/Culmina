from pathlib import Path
from datetime import datetime, timezone
import json, hashlib, shutil, subprocess, re

ROOT = next(p for p in Path(__file__).resolve().parents if (p/'pubspec.yaml').exists() and (p/'AGENTS.md').exists())
OUT = Path(__file__).parent
RENDERS = ROOT / 'design/reference/evidence/app-map-20261028/captures'
ATLAS = json.loads((ROOT/'design/reference/atlas/manifest.json').read_text(encoding='utf-8'))
NODES, EDGES = [], []
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def ref(path, text=None):
    p = ROOT/path
    lines = p.read_text(encoding='utf-8').splitlines()
    line = next((i+1 for i,s in enumerate(lines) if text and text in s), 1)
    return {'file':path, 'line':line, 'sha256':sha(p)}
def node(id, label, area, kind, routes, widget, path, shots, note='', anchor=None):
    NODES.append(dict(id=id,label=label,area=area,kind=kind,routes=routes,widget=widget,source=ref(path,anchor or ('class '+widget)),shots=shots.split(),note=note))
def edge(a,b,label,path,anchor,when=''):
    EDGES.append(dict(source=a,target=b,label=label,when=when,evidence=ref(path,anchor),verification='Current production caller; not a claim that every transition was exercised on Android'))
P='lib/presentation/'
S=P+'screens/'
node('tonight','Tonight','Tonight','Tab',['/tonight'],'TonightHomeScreen',S+'tonight/tonight_home_screen.dart','home home_timeline home_nosite','The tab can display a selected night other than tonight.')
node('candidates','What can I image?','Tonight','Screen',['/tonight/candidates'],'TonightCandidatesScreen',S+'tonight/tonight_candidates_screen.dart','home_candidates','Selecting a row changes the working target and returns to the caller; it does not create a scored recommendation.')
node('plan','Capture Plan','Plan','Root overlay',['/session/:id'],'HomeScreen',S+'home/home_screen.dart','plan plan_b plan_capture plan_gain_open plan_budget_assumptions plan_empty','SessionPlannerRoute wraps this screen. current opens the working plan; a numeric id can open a stored plan. Save is an action on this screen, not a destination.')
node('context','Site and night','Plan','Imperative page',[],'PlanContextScreen',S+'home/plan_context_screen.dart','plan_context','Apply changes updates the working draft. Close discards unapplied choices.')
node('choose_target','Choose target','Plan','Root overlay',['/select/target'],'PlanTargetScreen',S+'home/plan_target_screen.dart','plan_target','Scoped selection with Apply changes.')
node('choose_rig','Choose rig','Plan','Root overlay',['/select/rig'],'PlanRigScreen',S+'home/plan_rig_screen.dart','plan_rig','?for=plan preserves the create-and-select rig flow. An empty list can replace this screen with Manage rigs.')
node('block','Capture block editor','Plan','Imperative editor',[],'showCaptureBlockDialog',P+'widgets/capture_plan/capture_block_dialog.dart','plan_editor plan_editor_bottom','Despite its historical function name, this is a full-page editor. Add/Edit returns a block; the caller applies it with Undo.', 'Future<CaptureBlock?> showCaptureBlockDialog')
node('calibration','Build calibration frames','Plan','Imperative preview page',[],'_CalibrationPreview',P+'widgets/capture_plan/calibration_preview_dialog.dart','plan_cal plan_cal_b','A full-page preview, despite the historical dialog filename. Explicit application; calibration inside/outside the window and from a library remain distinct.')
node('assumptions','Plan assumptions','Plan','Imperative editor',[],'PlanOverridesEditor',P+'widgets/capture_plan/plan_overrides_editor.dart','plan_asm','These are per-plan overrides, separate from global planning defaults.')
node('plan_settings','Planning settings over Plan','Plan','Root overlay',['/plan/settings'],'SettingsScreen',S+'settings/settings_screen.dart','plan_settings','Global defaults; Back returns to Plan. Different scope from per-plan assumptions.')
node('guard','Unsaved changes','Shared','Dialog',[],'askUnsavedChanges',P+'shared/confirmation_patterns.dart','lib_rig_unsaved','Save / Discard / Cancel. The captured example is a Library editor; Plan wording and callers vary.', 'Future<UnsavedChoice> askUnsavedChanges')
node('night','Night','Conditions','Root overlay',['/night'],'NightMoonScreen',S+'details/night_moon_screen.dart','night night_reading_body night_exact_intervals','Night and Moon share a page controller; /moon opens the Moon page.')
node('moon','Moon','Conditions','Root overlay',['/moon'],'NightMoonScreen',S+'details/night_moon_screen.dart','moon moon_b','The Moon page of NightMoonScreen, not an independent bottom tab.')
node('weather','Weather','Conditions','Root overlay',['/weather'],'WeatherDetailScreen',S+'details/weather_detail_screen.dart','weather weather_charts_b weather_forecast_table weather_offline','Wrapper opens NightMoonScreen at page 2. Night / Moon / Weather are panes of one conditions browser; switching pane does not require a new router path. Forecast / cache / offline-refresh states remain distinct.')
node('logbook','Logbook','Logbook','Tab',['/sessions'],'LogbookScreen',S+'logbook/logbook_screen.dart','logbook','The technical route is /sessions; the visible tab is Logbook.')
node('entry','Saved plan / entry','Logbook','Branch detail',['/sessions/:id'],'SessionDetailScreen',S+'logbook/session_detail_screen.dart','entry entry_b','Shows planned and recorded information. Upcoming saved plans can reopen in Plan; other states offer record/edit result or copy.')
node('result','Record result','Logbook','Root overlay',['/session/:id/results'],'ResultsScreen',S+'execution/results_screen.dart','result','Recorded result is distinct from fit and a saved plan. Recording availability depends on the saved night and entry state.')
node('progress','Progress by target','Logbook','Branch detail',['/sessions/progress'],'ProgressScreen',S+'logbook/progress_screen.dart','logbook_progress progress_guide_open','Aggregates recorded results; a planned integration is not a recorded result.')
node('library','Library','Library','Tab',['/library'],'LibraryScreen',S+'library/library_screen.dart','library','Manages rigs, targets and sites.')
node('rigs','Rigs','Library','Branch list',['/library/rigs'],'EquipmentSelectionScreen',S+'equipment/equipment_selection_screen.dart','lib_rigs','ListMode.manage; tapping opens a record rather than silently selecting a plan rig.')
node('rig','Rig record','Library','Imperative detail',[],'RigDetailScreen',S+'equipment/rig_detail_screen.dart','lib_rig lib_rig_full','Existing profile with specifications and their evidence; no invented sensor data.')
node('rig_editor','Rig editor','Library','Imperative editor',[],'showEquipmentEditor',S+'equipment/equipment_editor.dart','lib_rig_edit rig_new','New, edit or metadata-prefilled draft; explicit Save rig.', 'Future<int?> showEquipmentEditor')
node('manage_rigs','Manage rigs over chooser','Library','Root overlay',['/manage/rigs'],'EquipmentSelectionScreen',S+'equipment/equipment_selection_screen.dart','manage_rigs','Same management screen in a different navigation context; ?for=plan can select a newly created rig.')
node('targets','Targets','Library','Branch list',['/library/targets'],'TargetSelectionScreen',S+'target/target_selection_screen.dart','lib_targets')
node('target','Target record','Library','Imperative detail',[],'TargetDetailScreen',S+'target/target_detail_screen.dart','lib_target','Plan this target starts a new plan after the leaving guard. A candidate-row tap has a different contract.')
node('target_editor','Target editor','Library','Imperative editor',[],'TargetEditorScreen',S+'target/target_editor_screen.dart','lib_target_new','Add/edit targets, including the existing catalogue edit path; untouched catalogue values retain their provenance.')
node('manage_targets','Manage targets over chooser','Library','Root overlay',['/manage/targets'],'TargetSelectionScreen',S+'target/target_selection_screen.dart','manage_targets','Library management above the scoped target chooser.')
node('sites','Sites','Library','Branch list',['/library/sites'],'SitesScreen',S+'sites/sites_screen.dart','lib_sites')
node('site','Site record','Library','Imperative detail',[],'SiteDetailScreen',S+'sites/site_detail_screen.dart','lib_site','Stored site and its provenance; not the transient map position.')
node('choose_site','Choose site','Location','Root overlay',['/select/site'],'SitesScreen',S+'sites/sites_screen.dart','select_sites','ListMode.choose; Tonight opens this directly. A row selects the site immediately without closing; the Manage site icon opens its record. Different from the unapplied choices in Plan context.')
node('site_editor','Site editor','Location','Root overlay',['/site/edit'],'SiteEditorScreen',S+'sites/site_editor_screen.dart','geo_add lib_site_edit','Receives typed SiteEditorArgs. Restored lost arguments return to Library sites instead of opening a different form.')
node('position','Current / transient position','Location','Root overlay',['/position'],'LocationPickerScreen',S+'location/location_picker_screen.dart','geo_map','Transient position for map/GPS; not equivalent to a stored selected site. Map tiles/GPS permission are platform boundaries.')
node('site_picker','Map coordinate picker','Location','Root overlay',['/site/pick'],'LocationPickerScreen',S+'location/location_picker_screen.dart','site_pick','pickOnly=true for the site editor; typed LatLng extra. Lost restored arguments return to Library sites.')
node('metadata','Add from a photo','Library','Root overlay',['/equipment/import'],'MetadataImportScreen',S+'metadata/metadata_import_screen.dart','metadata_ready','Review imported metadata and create a rig draft; native file-picker behavior is not verified by a host render.')
node('settings','Settings','Settings','Tab',['/settings'],'SettingsScreen',S+'settings/settings_screen.dart','settings')
node('appearance','Appearance','Settings','Imperative page',[],'SettingsScreen',S+'settings/settings_screen.dart','settings_appearance','Named MaterialPageRoute /settings/appearance, not a GoRoute. Theme, units and Android-controlled text size.')
node('defaults','Planning defaults','Settings','Imperative page',[],'SettingsScreen',S+'settings/settings_screen.dart','settings_planning','Named MaterialPageRoute /settings/planning; global settings with explicit draft Save.')
node('privacy','Privacy','Settings','Imperative page',[],'SettingsScreen',S+'settings/settings_screen.dart','settings_privacy','Named MaterialPageRoute /settings/privacy. Optional place-name lookup and its consent.')
node('backup','Backup & data','Settings','Imperative page',[],'SettingsScreen',S+'settings/settings_screen.dart','settings_backup','Named MaterialPageRoute /settings/backup. Backup, preview and restore operations have separate confirmation/platform boundaries.')
node('about','About','Settings','Root overlay',['/settings/about'],'AboutScreen',S+'about/about_screen.dart','settings_about')
node('licenses','Open-source licenses','Settings','Framework page',[],'LicensePage',S+'about/about_screen.dart','licenses','Opened with showLicensePage; not a custom named GoRoute.', 'showLicensePage(')
node('welcome','Welcome / setup','Startup','Root overlay',['/welcome'],'WelcomeScreen',S+'welcome/welcome_screen.dart','welcome welcome_b','First-run route is chosen from TonightViewModel state, not always shown on app launch.')

def e(a,b,label,file,anchor,when=''): edge(a,b,label,S+file,anchor,when)
for target,constant in [('plan','session()'),('candidates','candidates'),('night','nightMoon'),('moon','moon'),('weather','weather'),('choose_target','selectTarget'),('choose_rig','selectRigForPlan')]:
    e('tonight',target,{'plan':'Open planner','candidates':'What can I image?','night':'Night','moon':'Moon','weather':'Weather','choose_target':'Choose a target','choose_rig':'Choose a rig'}[target],'tonight/tonight_home_screen.dart','AppRouter.'+constant)
e('tonight','choose_site','Site context / Set site','tonight/home_context_sheets.dart','AppRouter.selectSite')
e('tonight','result','How did it go?','tonight/tonight_home_screen.dart','AppRouter.results','A saved entry is due for a result')
e('candidates','tonight','Choose target → return','tonight/tonight_candidates_screen.dart','await planVm.setTarget(t)')
for target,constant,label in [('choose_target','selectTarget','Target row'),('choose_rig','selectRig','Rig row'),('night','nightMoon','Night & Moon row'),('weather','weather','Weather row')]:
    e('plan',target,label,'home/home_screen.dart','AppRouter.'+constant)
e('plan','context','Site and night row','home/home_screen.dart','Future<void> openPlanContext')
edge('plan','block','Add / Edit block',P+'widgets/capture_plan_widget.dart','showCaptureBlockDialog(')
edge('plan','calibration','Build calibration frames',P+'widgets/capture_plan_widget.dart','showCalibration')
edge('plan','assumptions','Budget → Edit assumptions',P+'widgets/capture_plan/capture_assumptions_panel.dart','PlanOverridesEditor()')
edge('assumptions','plan','Apply per-plan changes',P+'widgets/capture_plan/plan_overrides_editor.dart','Navigator.of(context).pop')
edge('plan','plan_settings','Budget → Change in Settings',P+'widgets/capture_plan/capture_assumptions_panel.dart','AppRouter.planSettings')
e('context','choose_site','Manage sites','home/plan_context_screen.dart','AppRouter.selectSite')
e('context','plan','Apply changes / Close','home/plan_context_screen.dart','Navigator.of(context).pop')
e('choose_target','manage_targets','Add or manage targets','home/plan_target_screen.dart','AppRouter.manageTargets')
e('choose_target','plan','Apply choice → return','home/plan_target_screen.dart','Navigator.of(context).pop')
e('choose_rig','manage_rigs','Add or manage rigs','home/plan_rig_screen.dart','AppRouter.manageRigs','Empty initial list replaces chooser; ?for=plan preserves create-and-select')
e('choose_rig','plan','Apply choice → return','home/plan_rig_screen.dart','Navigator.of(context).pop')
edge('plan','guard','New / Copy replaces changed draft',P+'shared/unsaved_plan_prompt.dart','askUnsavedChanges(')
for target,constant,label in [('entry','sessionDetail','Open entry'),('progress','logbookProgress','Progress by target')]: e('logbook',target,label,'logbook/logbook_screen.dart','AppRouter.'+constant)
e('entry','plan','Open in planner','logbook/session_detail_screen.dart','AppRouter.session()','Upcoming editable plan; leave guard if replacing another changed plan')
e('entry','result','Record / Edit result','logbook/session_detail_screen.dart','AppRouter.results','Availability follows the saved night and result state')
e('entry','guard','Open / Copy over changed draft','logbook/session_detail_screen.dart','askBeforeLeavingPlan(context)')
for target,constant,label in [('rigs','libraryRigs','Rigs'),('targets','libraryTargets','Targets'),('sites','librarySites','Sites')]: e('library',target,label,'library/library_screen.dart','AppRouter.'+constant)
for origin in ['rigs','manage_rigs']: e(origin,'rig','Open rig record','equipment/equipment_selection_screen.dart','RigDetailScreen(rig: eq)')
for origin in ['targets','manage_targets']: e(origin,'target','Open target record','target/target_selection_screen.dart','TargetDetailScreen(')
for origin in ['sites','choose_site']: e(origin,'site','Open site record' if origin=='sites' else 'Manage site icon → record','sites/sites_screen.dart','SiteDetailScreen(siteId: site.id)')
for origin in ['rigs','manage_rigs']: e(origin,'rig_editor','Add / Edit rig','equipment/equipment_selection_screen.dart','showEquipmentEditor(')
e('rig','rig_editor','Edit rig','equipment/rig_detail_screen.dart','showEquipmentEditor(')
e('rig_editor','guard','Back with unsaved edits','equipment/equipment_editor.dart','askUnsavedChanges(')
for origin in ['targets','manage_targets']: e(origin,'target_editor','Add / Edit target','target/target_selection_screen.dart','showTargetEditor(')
e('target','target_editor','Edit target callback','target/target_selection_screen.dart','onEdit: (t)')
e('target','plan','Plan this target → new plan','target/target_selection_screen.dart','Future<void> _planThis','After Save / Discard / Cancel guard')
for origin in ['sites','choose_site']: e(origin,'site_editor','Add / Edit site','sites/sites_screen.dart','AppRouter.siteEdit')
e('site','site_editor','Edit site','sites/site_detail_screen.dart','AppRouter.siteEdit')
e('choose_site','position','Use current position / map','sites/sites_screen.dart','AppRouter.position')
e('site_editor','site_picker','Pick coordinates on map','sites/site_editor_screen.dart','AppRouter.sitePick')
for origin in ['rigs','manage_rigs']: e(origin,'metadata','Add from a photo','equipment/equipment_selection_screen.dart','AppRouter.metadata')
e('metadata','rig_editor','Use reviewed metadata → rig draft','metadata/metadata_import_screen.dart','showEquipmentEditor(')
for target in ['appearance','defaults','privacy','backup']:
    section={'defaults':'planning'}.get(target,target)
    e('settings',target,{'appearance':'Appearance','defaults':'Planning','privacy':'Privacy','backup':'Backup & data'}[target],'settings/settings_screen.dart','settings.open.'+section)
e('settings','about','About','settings/settings_screen.dart','AppRouter.about')
e('about','licenses','Licenses','about/about_screen.dart','showLicensePage(')
for a in ['night','moon','weather']:
    for b in ['night','moon','weather']:
        if a != b: e(a,b,'Switch conditions pane (same route context)','details/night_moon_screen.dart','TabBar(')
for target,const,label in [('tonight','tonight','Start planning'),('choose_site','selectSite','Set a site'),('choose_rig','selectRigForPlan','Choose a rig'),('metadata','metadata','Add from a photo')]: e('welcome',target,label,'welcome/welcome_screen.dart','AppRouter.'+const)

OUT.mkdir(exist_ok=True)
(OUT/'captures').mkdir(exist_ok=True)
captures=[]
for p in sorted(RENDERS.glob('*.json')):
    d=json.loads(p.read_text(encoding='utf-8'))
    if not d.get('fixtureSucceeded'): continue
    png=p.with_suffix('.png')
    if not png.exists(): continue
    for f in [p,png]: shutil.copy2(f,OUT/'captures'/f.name)
    old=next((c for c in ATLAS['captures'] if c['name']==d['name']),None)
    captures.append(dict(name=d['name'],file='captures/'+png.name,metadata='captures/'+p.name,sha256=sha(png),atlasId=old['id'] if old else None,surface=old['surface'] if old else d['name'].replace('_',' '),route=d['route'],visibleScreens=d['visibleScreens'],sourceHead=d['sourceHead'],runStartedUtc=d['captureUtc'],writtenUtc=datetime.fromtimestamp(png.stat().st_mtime,timezone.utc).isoformat()))
capture_names={c['name'] for c in captures}
for n in NODES:
    n['availableShots']=[s for s in n['shots'] if s in capture_names]
    n['evidence']='Fresh Flutter host' if n['availableShots'] else 'Source only — no accepted fresh render'
data=dict(title='Culmina — current application map',date='2026-10-28',head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),branch='develop',nodes=NODES,edges=EDGES,captures=captures,atlasBaseline=ATLAS['baseline'],atlasCount=40,atlasManifestSha256=sha(ROOT/'design/reference/atlas/manifest.json'),atlasImagesReused=False,fixture='Synthetic data; frozen clock 2026-10-18T15:00Z, planned night 2026-10-19, Europe/Kyiv. Real current production widgets/fonts/router/ViewModels/domain; in-memory SQLite. Dark / 100% / 375×812 / DPR 1.',limits='Fresh host renders establish captured compositions only. Edges are traced from current production callers, not an exhaustive interaction test. Android, TalkBack, all error states, themes and text scales are not revalidated by this map. System file pickers, permissions and external share/map endpoints are boundaries, not internal routes.',tabNavigation=dict(roots=['tonight','logbook','library','settings'],behavior='Bottom tabs exist only at the four root paths. Each branch keeps its stack. A reselected tab can reset its branch; Back at another root returns to Tonight. Root overlays and detail pages return to their caller.'),stateModel=[dict(label='Working draft',meaning='Edits can be persisted for recovery; this is not explicit Save plan.'),dict(label='Saved plan',meaning='Explicit snapshot. Later changes are Saved · changed until saved again.'),dict(label='Fit verdict',meaning='Independent time-placement analysis: not a persistence or result state.'),dict(label='Recorded result',meaning='Reported imaging outcome; not implied by planned integration or Fits.')])
(OUT/'map.json').write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf-8')
sources={n['source']['file']:n['source']['sha256'] for n in NODES}
sources.update({e['evidence']['file']:e['evidence']['sha256'] for e in EDGES})
manifest=dict(head=data['head'],generatedUtc=datetime.now(timezone.utc).isoformat(),atlasReference=dict(baseline=ATLAS['baseline'],manifestSha256=data['atlasManifestSha256'],originalCount=40,refreshedCount=sum(bool(c['atlasId']) for c in captures),historicalPixelsReused=False),captureCount=len(captures),nodeCount=len(NODES),edgeCount=len(EDGES),goRoutePatterns=sorted({p for n in NODES for p in n['routes']}),sourceHashes=sources,captures=captures,limitations=data['limits'],gitPorcelain=subprocess.check_output(['git','status','--porcelain=v1'],cwd=ROOT,text=True))
(OUT/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
template=(OUT/'map-template.html').read_text(encoding='utf-8')
(OUT/'index.html').write_text(template.replace('__MAP_DATA__',json.dumps(data,ensure_ascii=False).replace('</','<\\/')),encoding='utf-8')
print(json.dumps(dict(nodes=len(NODES),edges=len(EDGES),captures=len(captures),atlasRefreshed=manifest['atlasReference']['refreshedCount'],sourceOnly=[n['id'] for n in NODES if not n['availableShots']]),indent=2))
if (OUT/'extend_design.py').exists():
    import sys
    subprocess.run([sys.executable,str(OUT/'extend_design.py')],check=True,cwd=ROOT)
