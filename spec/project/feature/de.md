# Projekt-Feature

Status: draft

## Kontext

Leser: Repo-Maintainer von Hobby-Projekten im nolte-Portfolio, die die Skills `feature-decompose`, `sprint-execute` und `sprint-review` aufrufen (die letzten beiden lesen Features, besitzen sie aber nicht), den Agent `feature-consistency-reviewer`, sowie die Implementierer dieser Skills und des Agents, die gegen das hier definierte Schema bauen.

Die Geschwister-Spec `roadmap` definiert, welche Arbeit ansteht und warum; die Geschwister-Spec `sprint` definiert, wie Arbeit gruppiert und ausgeliefert wird. Dazwischen sitzt die Ausführungseinheit: ein Feature. Ein Feature im nolte-Portfolio ist eine über Markdown verwaltete, sprint-gebundene, roadmap-verknüpfte Stück nutzersichtbarer Veränderung. Es ist das kleinste Objekt, das Akzeptanzkriterien trägt, das kleinste Objekt, auf dem konsumierende Claude-Skills (`feature-decompose`, `sprint-execute`, der Agent `feature-consistency-reviewer`) operieren, und das kleinste Objekt, dessen Zustandsmaschine von Sprint-Ebene aus beobachtbar ist. Diese Spec legt Datei-Form, Schema, Lifecycle und — einzigartig auf dieser Ebene — eine **verpflichtende Konsistenzprüfung** gegen bestehende Features und bestehenden Quellcode fest, bevor ein neues Feature als bereit gilt: Hobby-Projekte sammeln schnell latente Überlappungen an, und eine Authoring-Schicht, die diese nicht sichtbar macht, lässt sie ungebremst wachsen.

## Ziele

- Die Datei-Form eines Features als eine einzige Markdown-Datei unter `project/features/<slug>.md` festlegen, eine Datei pro Feature, mit stabilem Frontmatter-Schema und verpflichtenden Body-Sections, damit konsumierende Skills Features deterministisch parsen, ändern und validieren können.
- Den Feature-Lifecycle festlegen (`draft → ready → in_progress → done`, plus `cancelled`) und die Mindest-Gates pro Übergang, damit Authoring, Ausführung und Abschluss in nicht überlappenden Skill-Zuständigkeiten leben.
- Die **Konsistenzprüfung** erzwingen: bevor ein Feature `draft` verlässt, **MUSS [MUST]** es gegen den bestehenden Feature-Bestand und gegen die bestehende Quellcode-Oberfläche auf Überlappung, Duplikation und Drift geprüft werden; die Prüfung wird an den Agent `feature-consistency-reviewer` delegiert, und die Befunde **MÜSSEN [MUST]** am Feature selbst dokumentiert werden.
- Jedes Feature an genau ein Roadmap-Item (`R-<n>`) und einen Sprint (`<NNNN>`) zurückbinden, damit Nachverfolgbarkeit lückenlos von Roadmap → Sprint → Feature → Akzeptanzkriterium → ausrollbarem Artefakt fließt.
- Einen klaren Akzeptanzkriterien-Vertrag festlegen: Kriterien sind testbar, einzeln abhakbar, und mindestens ein Kriterium pro Sprint ist nötig, um das `value_statement` des Sprints zu prüfen (die Anforderung wird sprint-seitig erzwungen, aber die **Form** eines Akzeptanzkriteriums plus der **Frontmatter-Marker**, der das mehrwert-prüfende Kriterium kennzeichnet, werden hier definiert).
- Portfolio-weit wiederverwendbar bleiben: jeder im Portfolio unterstützte Projekttyp (Claude-Plugin, Python-Anwendung, Python-Bibliothek, Node / TypeScript, CLI-Tool, dokumentations-only) kann das Schema **unverändert** übernehmen: das Frontmatter-Schema und die Body-Sections sind über alle Projekttypen identisch, typ-spezifische Hinweise leben nur in Body-Inhalten (Description-Sprache, Test-Hook-Konventionen) und **DÜRFEN NICHT [MUST NOT]** das Schema oder die Section-Liste pro Projekttyp verzweigen.

## Nicht-Ziele

- Roadmap-, Sprint- oder Release-Artefakt-Innenleben festzulegen. Jedes davon gehört seiner eigenen Geschwister-Spec; diese Spec erklärt nur die Feature-seitige Oberfläche und die Querverweise, die sie trägt.
- Test-Frameworks zu ersetzen. Akzeptanzkriterien verweisen auf Tests, manuelle Demo-Schritte oder Skill-Aufrufe; die Feature-Spec führt sie nicht aus, sondern listet und verfolgt sie nur.
- Eine spezifische Implementierungssprache oder ein Framework zu erzwingen. Die Spec regelt Authoring- und Tracking-Form, nicht das Wie der Umsetzung.
- `audience-identification`- oder audience-doc-author-Tooling zu ersetzen. Feature-Dokumentation für Endnutzer gehört zur Doc-Author-Oberfläche; das Feature-Markdown ist ein internes Planungs-Artefakt.
- `continuous-improvement`, `spec-drift-audit` oder `spec-readiness` zu ersetzen. Diese regeln Prozess und Spec-Hygiene; diese Spec regelt Feature-Artefakt-Hygiene.
- Die Logik des `feature-consistency-reviewer`-Agents zu ersetzen. Die Untersuchungs-Oberfläche des Agents (welche Pfade zu lesen sind, wie Überlappung bewertet wird) ist seine eigene Sache; diese Spec verlangt nur, **dass** die Prüfung passiert und **was** dokumentiert wird.

## Anforderungen

### Verzeichnislayout und Datei-Form

- **MUSS [MUST]** jedes Feature unter `project/features/<slug>.md` ablegen, wobei `<slug>` eine ASCII-kebab-case-Zusammenfassung des Feature-Titels ist, stabil über die gesamte Lebensdauer des Features.
- **MUSS [MUST]** genau eine Markdown-Datei pro Feature führen; Feature-Inhalt wird nie über mehrere Dateien gesplittet.
- **DARF NICHT [MUST NOT]** den Slug eines Features umbenennen, nachdem es `draft` verlassen hat; Umbenennungen brechen Sprint- und Roadmap-Rück-Referenzen still.
- **SOLLTE [SHOULD]** `<slug>` so kurz halten, dass er in Verzeichnislisten lesbar bleibt (≤ 6 Wörter kebab-cased ist die Zielform).

### Frontmatter-Schema

- **MUSS [MUST]** die Datei mit einem YAML-Frontmatter-Fence öffnen, der folgende Felder in dieser Reihenfolge trägt:
  - `id` (String, verpflichtend) — Muster `F-<n>`, projektweit monoton vergeben, niemals wiederverwendet;
  - `title` (String, verpflichtend) — einzeilige Zusammenfassung in der Hauptsprache des Projekts;
  - `status` (Enum, verpflichtend) — einer von `draft`, `ready`, `in_progress`, `done`, `cancelled`;
  - `roadmap_item` (String, verpflichtend) — die `R-<n>`-ID, die dieses Feature zerlegt; **MUSS [MUST]** zu einem Eintrag in `project/roadmap.md` matchen;
  - `sprint` (Integer oder null, verpflichtend) — die Sprint-Nummer, für die das Feature eingeplant ist; null während `draft` und während `ready` so lange das Feature von keinem Sprint übernommen wurde. Das Feld wechselt genau dann von null auf nicht-null, wenn das Feature laut `spec/project/sprint/` in die `features`-Liste eines Sprints aufgenommen wird; die kanonische Schreib-Autorität ist `sprint-plan` (wenn vor der Aktivierung geplant wird) oder `sprint-execute` (wenn das Feature mitten in einem aktiven Sprint aufgenommen wird), und jede der beiden **MUSS [MUST]** `feature.sprint = N` in derselben Operation schreiben, die `feature.id` zu `sprints/N.features` hinzufügt. Das Feld **DARF NICHT [MUST NOT]** von Hand oder durch einen anderen Skill gesetzt werden; die bidirektionale Invariante (Feature-Seite ↔ Sprint-Seite) ist die kanonische Prüfung;
  - `created` (ISO-Datum, verpflichtend) — Datum, an dem die Feature-Datei erstmals geschrieben wurde; nach Erstellung nie editiert;
  - `ended` (ISO-Datum oder null, verpflichtend) — Datum, an dem das Feature entweder `done` oder `cancelled` erreicht hat (beide terminalen Zustände teilen dieses Feld, daher der neutrale Name); null bis das Feature terminal ist;
  - `verifies_sprint_value` (String oder null, verpflichtend) — der Akzeptanzkriterium-Bezeichner (`acceptance-<n>`) auf diesem Feature, der beim Abhaken das `value_statement` des Sprints direkt prüft; nicht-null auf höchstens einem Feature pro Sprint, sonst null. Die Geschwister-Spec `sprint` verlangt, dass in jedem schließenden Sprint **mindestens ein** Feature hier einen nicht-null-Wert trägt; zusammen mit der hier feature-seitig durchgesetzten At-most-one-Schranke (siehe §Akzeptanzkriterien-Vertrag und das AC weiter unten) ergibt sich netto die Bedingung "genau eines". Schreib-Autorität ist `feature-decompose` (wenn das verifizierende Kriterium bei der Decomposition identifiziert wird) oder `sprint-plan` (wenn das verifizierende Kriterium während der Planung neu zugewiesen wird); das Feld **MUSS [MUST]** auf genau einem Feature pro Sprint nicht-null sein, **bevor** dieser Sprint nach `review` übergeht;
  - `consistency_check` (Objekt, verpflichtend) — siehe §Konsistenzprüfung-Schema unten.
- **DARF NICHT [MUST NOT]** Aufwandsschätzungen, Punkte oder Zuweisungsfelder jenseits der oben deklarierten enthalten; Lints flaggen unbekannte Schlüsselwörter.

### Body-Sections

- **MUSS [MUST]** folgende Level-2-Sections in dieser Reihenfolge tragen, auch wenn leer (Skills hängen an stabilen Section-Überschriften):
  - `## Description` — ein bis drei Absätze, die die nutzersichtbare Veränderung beschreiben; in der Hauptsprache des Projekts geschrieben; aus Endnutzer-Sicht formuliert, wann immer möglich.
  - `## Acceptance criteria` — Checkliste testbarer, einzeln abhakbarer Bedingungen; siehe §Akzeptanzkriterien-Vertrag für die Form pro Eintrag.
  - `## Test hooks` — explizite Liste, welche Tests, Skills oder manuellen Demo-Schritte welche Akzeptanzkriterien validieren. Jeder Eintrag **MUSS [MUST]** drei Komponenten tragen: (a) den `acceptance-<n>`-Bezeichner, an den er pinnt; (b) den Verifikations-Mechanismus (Test-Pfad, Skill-Name, CLI-Befehl oder manuelles Vorgehen); (c) ein Status-Token aus dem geschlossenen Vokabular `pending` (noch nicht ausgeführt), `passing` (ausgeführt und erfolgreich), `skipped` (für diesen Lauf bewusst nicht ausgeführt, mit Begründung) oder `failing` (ausgeführt und nicht erfolgreich). Format: `- **acceptance-<n>** — <Mechanismus> — <Status>`. Ein Hook gilt für das Lifecycle-Gate (siehe §Lifecycle und Gates) nur dann als "aufgelöst", wenn sein Status `passing` oder `skipped` ist.
  - `## Consistency notes` — wird durch die Konsistenzprüfung befüllt (siehe §Konsistenzprüfung); fasst die Befunde des Agents und die für jeden Befund gewählte Auflösung zusammen.
  - `## Risks` — bekannte Unbekannte, Blocker oder Mitigationen; **KANN [MAY]** für risikoarme Features leer sein.
- **KANN [MAY]** zusätzliche Level-2-Sections tragen (`## Open questions`, `## References`), wenn das Feature sie wirklich braucht; **DARF NICHT [MUST NOT]** die Reihenfolge der verpflichtenden Sections wegen optionaler ändern.

### Akzeptanzkriterien-Vertrag

- **MUSS [MUST]** jedes Akzeptanzkriterium als Markdown-Checkbox-Bullet (`- [ ] …`) formulieren, ein Kriterium pro Bullet, atomar (eine einzelne Prüfung), testbar (ein Reviewer kann eindeutig Erledigt/Nicht-Erledigt markieren).
- **MUSS [MUST]** einen stabilen, pro-Feature eindeutigen Kriterium-Bezeichner im Bullet-Text vergeben, im Muster `acceptance-<n>` (zum Beispiel `- [ ] **acceptance-1** Sensorwert erscheint innerhalb von 5 s nach Geräte-Discovery`); dieser Bezeichner wird vom Frontmatter-Feld `verifies_sprint_value` referenziert und ist das, woran `## Test hooks`-Einträge gepinnt werden.
- **DARF NICHT [MUST NOT]** prozess-interne Kriterien tragen ("PR genehmigt", "in develop gemerged"); Akzeptanzkriterien sind nutzersichtbares Verhalten, keine Workflow-Gates.
- **SOLLTE [SHOULD]** drei bis sieben Kriterien pro Feature anpeilen; eines ist verdächtig (unterspezifiziert), mehr als zehn legt nahe, dass das Feature gesplittet werden sollte.
- **DARF NICHT [MUST NOT]** sich auf Prosa-Marker im Bullet-Text verlassen, um das mehrwert-prüfende Kriterium zu identifizieren; das einzige autoritative Signal ist das Frontmatter-Feld `verifies_sprint_value`. Autoren **KÖNNEN [MAY]** die Verifizierungs-Rolle in menschenlesbarer Prosa zur Lesefreundlichkeit erwähnen, aber konsumierende Skills **MÜSSEN [MUST]** das Frontmatter parsen, nicht den Bullet-Text.

### Konsistenzprüfung

- **MUSS [MUST]** eine Konsistenzprüfung durchführen, bevor ein Feature von `draft` nach `ready` übergeht. Kanonischer Ausführer ist der Agent `feature-consistency-reviewer` (laut `spec/claude/agent-management/`); bis dieser Agent existiert, **KANN [MAY]** ein operator-getriebener manueller Durchgang dieselbe Anforderung erfüllen, **vorausgesetzt** er folgt derselben Investigations-Oberfläche und Aufzeichnungs-Form, der manuelle Durchgang wird mit `agent_version: manual-<YYYY-MM-DD>` in `consistency_check` festgehalten und die `## Consistency notes`-Section nennt den ausführenden Operator. Sobald der Agent existiert, **MUSS [MUST]** der manuelle Fallback entfernt werden, und jedes Feature, das sich danach noch darauf stützt, ist ein workflow-health-Finding. Die Prüfung (egal ob Agent oder manuell) untersucht:
  - den bestehenden Feature-Bestand unter `project/features/` auf überlappende oder widersprechende Features;
  - die bestehende Quellcode-Oberfläche (die primären Source-Roots des Projekts, identifiziert über Repo-Konventionen) auf bereits implementiertes Verhalten, das das neue Feature neu implementieren würde; die Quellcode-Oberfläche folgt demjenigen Primary-Source-Layout, das `spec/project/project-structure/` für das konsumierende Repo anerkennt, sodass bei einem Claude-Code-Plugin-Repo die Oberfläche ausdrücklich `skills/<name>/SKILL.md`, `agents/<name>.md` und `.claude-plugin/plugin.json` **einschließt** (das ausführbare Verhalten des Plugins lebt in diesen Dateien, auch wenn sie Markdown sind), genauso wie sie bei Repos mit anderen Layouts `src/`, `src/<component>/`, `custom_components/<name>/`, `playbooks/` und `roles/` einschließt;
  - den Spec-Bestand unter `spec/` auf frühere Entscheidungen, die dieses Feature einschränken.
- **MUSS [MUST]** die Befunde des Agents am Feature in der Body-Section `## Consistency notes` und als strukturiertes Frontmatter-Objekt `consistency_check` mit folgenden Feldern dokumentieren:
  - `performed_at` (ISO-Datum, verpflichtend) — wann die Prüfung lief;
  - `agent_version` (String, optional) — Agent-Bezeichner, damit Re-Runs diffbar sind;
  - `findings` (Liste, verpflichtend) — jeder Befund mit `kind` (`overlap`, `duplication`, `drift`, `prior-art`, `clean`), `target` (Dateipfad oder Feature-ID, auf die er sich bezieht) und `resolution` (`merge-into <id>`, `supersede <id>`, `split-out <ids>`, `proceed`, `revisit-after <event>`).
- **MUSS [MUST]** jeden Befund mit `kind: overlap` oder `kind: duplication` als Blocker für den Übergang `draft → ready` behandeln, sofern seine `resolution` nicht `proceed` mit einer expliziten ein-absätzigen Begründung in `## Consistency notes` ist.
- **MUSS [MUST]** die Konsistenzprüfung erneut laufen lassen, sobald während des Status `ready` oder `in_progress` eines der folgenden Ereignisse eintritt: die `## Description`-Section ändert sich über Tippfehler-Niveau hinaus, ein Akzeptanzkriterium wird hinzugefügt oder seine Kern-Formulierung (ohne den Checkbox-Zustand) geändert, das Frontmatter-Feld `roadmap_item` oder `sprint` wird geändert, oder ein Feature mit überlappendem Scope wird anderswo unter `project/features/` hinzugefügt oder entfernt. Der Re-Run **MUSS [MUST]** historische Befunde bewahren (einen neuen `findings`-Block mit `performed_at`-Datum anhängen, nicht überschreiben). Kosmetische Änderungen (Tippfehler-Korrekturen, Formatierung, Link-Ziel-Normalisierung, das Umschalten der Bullet-Checkbox eines bestehenden Akzeptanzkriteriums) **DÜRFEN NICHT [MUST NOT]** einen Re-Run auslösen.
- **MUSS [MUST]** die Befunde inline am Feature dokumentieren (im `consistency_check`-Frontmatter und in `## Consistency notes`), niemals als separates `.audits/feature-consistency/`-Artefakt. Anders als die transienten `skill-review`/`agent-review`-Pläne unter `.audits/` (die `spec/claude/review-plan/` als nach Abschluss löschbare Arbeitsdokumente definiert) sind Konsistenz-Befunde dauerhafte, nur-anhängende Feature-Metadaten, die den Lifecycle `draft → ready` gaten und daher am Feature selbst leben.
- **MUSS [MUST]** das `consistency_check`-Objekt unabhängig von der Länge der `findings`-Historie inline am Feature halten; eine Auslagerung in eine separate Datei ist entschieden-dagegen, weil die Befunde den Lifecycle gaten und am Feature selbst diffbar bleiben müssen.

### Lifecycle und Gates

- **MUSS [MUST]** `status` nur entlang dieser Pfade übergehen lassen: `draft → ready`, `ready → in_progress`, `in_progress → done` und `cancelled` aus jedem von `draft`, `ready`, `in_progress` erreichbar. Direktes `draft → in_progress`, `draft → done` und `ready → done` ist verboten, weil es die Konsistenzprüfung oder das Ausführungs-Gate überspringt.
- **MUSS [MUST]** vor `draft → ready` verlangen: ein nicht-leeres `## Description`, mindestens ein Akzeptanzkriterium-Bullet, ein befülltes `consistency_check`-Frontmatter und eine befüllte `## Consistency notes`-Section.
- **MUSS [MUST]** vor `ready → in_progress` verlangen: einen nicht-null `sprint`-Wert, der entweder dem aktuell `active` Sprint oder dem niedrigst-nummerierten `planned`-Sprint laut Geschwister-Spec `sprint` entspricht, und das Feature ist im `features`-Feld dieses Sprints gelistet. Ist der gematchte Sprint `planned`, befördert `sprint-execute` ihn als Seiteneffekt dieses Übergangs automatisch nach `active` (laut `sprint` §Lifecycle); ist bereits ein anderer Sprint `active`, wird der Übergang abgelehnt.
- **MUSS [MUST]** vor `in_progress → done` verlangen: jedes Akzeptanzkriterium abgehakt, jeder Test-Hook aufgelöst (Status `passing` oder `skipped` laut §Body-Sections) und der Sprint des Features entweder `active` oder `review`.
- **KANN [MAY]** zu jedem Zeitpunkt vor `done` nach `cancelled` übergehen; der Übergang **MUSS [MUST]** eine ein-absätzige Begründung tragen, in `## Risks`, wenn das Feature vor dem Konsistenzprüfungs-Lauf abgebrochen wurde (Status `draft` zum Abbruchszeitpunkt), und in `## Consistency notes`, wenn das Feature im Status `ready` oder `in_progress` abgebrochen wurde, weil die Konsistenzprüfung oder ein späterer Befund zeigte, dass das Feature nicht gebaut werden sollte.

### Roadmap-, Sprint- und Source-Verknüpfung

- **MUSS [MUST]** sicherstellen, dass `roadmap_item` auf ein in `project/roadmap.md` deklariertes `R-<n>` auflöst; ein Feature ohne Roadmap-Verknüpfung ist auch dann ungültig, wenn die ursprüngliche Motivation "interne Härtung" ist — ein Roadmap-Item für die Härtungs-Absicht zuerst deklarieren.
- **MUSS [MUST]** sicherstellen, dass — wenn `sprint` nicht null ist — die `features`-Frontmatter-Liste der referenzierten Sprint-Datei die `id` dieses Features enthält; die Rück-Referenz ist bidirektional und wird bei jeder Sprint- und Feature-Änderung validiert.
- **MUSS [MUST]** zulassen, dass `## Test hooks` auf Source-Pfade, Test-Pfade oder Skill-Namen zeigt; die Spec schränkt nicht ein, welchen Mechanismus ein Hook wählt, nur dass der Mechanismus explizit benannt ist, damit die Konsistenzprüfung Vorarbeit lokalisieren kann.
- **KANN [MAY]** Verweise auf externe Issues (GitHub-Issues, Project-Boards) in `## Description` oder `## References` tragen; diese Verweise sind Dokumentation, niemals autoritativ.

### Hobby-Skala-Varianz

- **DARF NICHT [MUST NOT]** Aufwandsschätzungen, Fälligkeitsdaten oder Velocity-Tracking auf Features verlangen; wie Roadmap-Items und Sprints sind Features im Tempo des Autors.
- **SOLLTE [SHOULD]** lange Strecken zwischen Konsistenzprüfung und Ausführung tolerieren; vergehen mehr als zwei Sprints ohne Ausführung, **SOLLTE [SHOULD]** die Konsistenzprüfung vor `ready → in_progress` erneut laufen.
- **KANN [MAY]** ein Feature `cancelled` markieren, wenn die Konsistenzprüfung zeigt, dass ein bestehendes Feature es bereits abdeckt; Abbruch mit `resolution: merge-into <id>` ist ein erstklassiges Ergebnis, kein Fehlerzustand.
- **MUSS [MUST]** auf dokumentations-only-Features (eine How-to-Seite, ein Runbook) das identische Schema und denselben Lifecycle anwenden; die No-per-Type-Branching-Regel (Ziel 6) lässt keine Doc-Feature-Ausnahme zu, und ein Doc-Feature bleibt ein internes Planungs-Artefakt, das denselben Akzeptanzkriterien-, Test-Hook- und Konsistenz-Vertrag trägt wie jedes andere Feature.

## Akzeptanzkriterien

- [ ] Jedes Feature existiert als genau eine Datei unter `project/features/<slug>.md` mit stabilem Slug; kein Slug wird umbenannt, nachdem das Feature `draft` verlassen hat.
- [ ] Das Frontmatter jedes Features trägt die neun Schema-Felder (`id`, `title`, `status`, `roadmap_item`, `sprint`, `created`, `ended`, `verifies_sprint_value`, `consistency_check`) in der festgelegten Reihenfolge; Lints flaggen unbekannte Schlüsselwörter und lehnen `closed` als Frontmatter-Feldname ab (das Feld heißt `ended`).
- [ ] Der Body jedes Features trägt die fünf verpflichtenden Level-2-Sections (`Description`, `Acceptance criteria`, `Test hooks`, `Consistency notes`, `Risks`) in der festgelegten Reihenfolge; fehlende Sections schlagen die Validierung.
- [ ] Jedes Akzeptanzkriterium-Bullet nutzt das Muster `**acceptance-<n>**` und ist atomar, testbar und nutzersichtbar (kein Workflow-Gate); kein Bullet trägt einen Inline-Mehrwert-Verifizier-Marker (das einzige autoritative Signal ist das Frontmatter-Feld `verifies_sprint_value`).
- [ ] Jeder `## Test hooks`-Eintrag pinnt an einen `acceptance-<n>`-Bezeichner, benennt einen Verifikations-Mechanismus und trägt ein Status-Token aus dem geschlossenen Vokabular (`pending`, `passing`, `skipped`, `failing`); Einträge ohne eine der drei Komponenten schlagen die Validierung.
- [ ] Kein Feature wechselt `draft → ready` ohne ein befülltes `consistency_check`-Frontmatter-Objekt, dessen `findings`-Array nicht leer ist (auch ein sauberer Lauf wird mit `kind: clean` dokumentiert), und eine befüllte `## Consistency notes`-Section.
- [ ] Kein Feature wechselt `ready → in_progress`, solange ein anderer Sprint als der in seinem `sprint`-Feld referenzierte `active` ist; das Gate wird von `sprint-execute` durchgesetzt und löst die `planned → active`-Beförderung aus, wenn anwendbar.
- [ ] Kein Feature wechselt `in_progress → done`, solange ein Akzeptanzkriterium-Bullet ungeprüft oder der Status eines Test-Hooks `pending` oder `failing` ist.
- [ ] Es treten keine direkten Übergänge für `draft → in_progress`, `draft → done` oder `ready → done` auf; Verstöße gegen den Übergangsgraphen werden von den konsumierenden Skills abgelehnt.
- [ ] Jeder `consistency_check.findings`-Eintrag mit `kind` `overlap` oder `duplication` hat entweder eine nicht-`proceed`-Auflösung oder trägt eine ein-absätzige Begründung in `## Consistency notes`, die die `proceed`-Wahl rechtfertigt.
- [ ] Höchstens ein Feature pro Sprint trägt einen nicht-null `verifies_sprint_value`; Sprints, die mit null oder mehr als einem solchen Feature schließen, schlagen die sprint-seitige Validierung laut Geschwister-Spec `sprint`.
- [ ] Jedes abgebrochene Feature trägt eine ein-absätzige Begründung: in `## Risks`, wenn im `draft` abgebrochen, in `## Consistency notes`, wenn im `ready` oder `in_progress` abgebrochen. Fehlende Begründung schlägt die Validierung.
- [ ] Kein Feature-Schema verzweigt nach Projekttyp; das Schema und die Body-Section-Liste sind über Claude-Plugin, Python-Anwendung, Python-Bibliothek, Node / TypeScript, CLI-Tool und dokumentations-only-Repos identisch.

## Offene Fragen

- Cross-Feature-Abhängigkeiten (`F-7 braucht F-3 zuerst`) tragen heute kein Schema-Feld; die Sprint-Zugehörigkeit plus die `roadmap_item`-Verknüpfung drücken die einzige existierende Sequenzierung aus. Revisitieren, sobald eine echte Feature-Kette auftaucht, die die Sprint-Reihenfolge nicht ausdrücken kann—konkret: zwei Features landen, bei denen die `## Acceptance criteria` oder `## Test hooks` des späteren auf ein Verhalten verweisen, das das frühere einführt, beide sind in DENSELBEN `sprint` eingeplant (sodass die Sprint-Reihenfolge sie nicht sequenzieren kann), UND die Konsistenzprüfung kann die Reihenfolge nicht als `prior-art`/`revisit-after`-Befund erfassen. Das erste solche Auftreten gibt frei, `depends_on` SOWOHL dem Feature-Schema ALS AUCH der Geschwister-Spec `sprint` im Gleichschritt hinzuzufügen (die Sprint-Spec trägt heute kein Abhängigkeits- oder Reihenfolge-Feld, sodass eine nur feature-seitige Ergänzung eine einseitige Invariante wäre).
