# Projekt-Mission

Status: draft

## Kontext

Leser: Repo-Maintainer von Hobby-Projekten im nolte-Portfolio, die die Skills `mission-define` und `mission-revise` aufrufen (sobald diese existieren), die Operatoren, die `mvp_status` eines Projekts bei der Stabilisierung umlegen, sowie die Implementierer dieser Skills, die gegen das hier definierte Schema bauen.

Bestehende Portfolio-Specs regeln, welche Arbeit ansteht (`roadmap`), wie Arbeit gruppiert wird (`sprint`), die Ausführungseinheit (`feature`) und wie Releases ausgeliefert werden (`release-artifact`, `release-automation`). Was bisher nicht erklärt ist: **warum das Projekt überhaupt existiert, für wen, und welche Teilmenge der eingereihten Arbeit das Minimum ist, das diesen Zweck wirklich erfüllt**. Diese Spec füllt diese Lücke. Ein Mission Statement im nolte-Portfolio ist ein über Markdown verwalteter, audience-spezifisch zugeschnittener, SMART-konformer Satz, der die Roadmap verankert: er bindet jedes eingereihte Item zurück an einen erklärten Zweck, trennt das **MVP** (die minimale nutzbare Oberfläche, die die Mission belegt) von der **Post-MVP-Abgrenzung** (explizit benannt, damit die Grenze sichtbar bleibt), und macht Post-MVP-Arbeit von der MVP-Stabilisierung abhängig. Die Pflicht zum Audience-Tailoring ist tragend: ein Mission Statement, das nicht auf das Audience-Artefakt des Projekts auflöst, ist ein privates Ziel, keine Portfolio-Mission.

## Ziele

- Die Datei-Form einer Projekt-Mission als eine einzige Markdown-Datei unter `project/mission.md` festlegen, parallel zu `project/roadmap.md` und `project/goals.md`, mit stabilem Frontmatter-Schema und verpflichtenden Body-Sections, damit konsumierende Skills die Mission deterministisch parsen, ändern und validieren können.
- SMART für das Hobby-Skala-Portfolio formalisieren: jeder der fünf Buchstaben wird zu einer eigenen prüfbaren Anforderung, wobei der **Time-bound**-Anteil als Outcome-oder-MVP-Completion-Referenz ausgedrückt wird, nicht als Kalenderdatum.
- Die **MVP-Definition** festlegen als minimale Teilmenge der Roadmap-Items, deren Abschluss die Mission über den bestehenden `verifies_sprint_value`-Mechanismus aus der Geschwister-Spec `feature` belegt; hier wird kein neuer Verifikations-Mechanismus eingeführt.
- Das **Stabilisierungs-Gate** festlegen: Post-MVP-Roadmap-Items (`mvp: false`) **DÜRFEN NICHT [MUST NOT]** auf `status: active` wechseln, bevor das MVP als ganzes **stabilisiert** ist, und diese Spec definiert die exakten Bedingungen, unter denen der Operator `mvp_status` auf `stabilised` umlegen darf.
- **Audience-Tailoring** erzwingen: für jede Audience in `audiences` **MUSS [MUST]** der Body erklären, was das MVP dieser Audience liefert; eine Audience ohne zugehörigen Tailoring-Absatz schlägt die Validierung.
- Portfolio-weit wiederverwendbar bleiben: jeder im Portfolio unterstützte Projekttyp (Claude-Plugin, Python-Anwendung, Python-Bibliothek, Node / TypeScript, CLI-Tool, dokumentations-only) kann das Schema unverändert übernehmen; typ-spezifische Hinweise leben nur in Body-Inhalten, niemals im Frontmatter-Schema.

## Nicht-Ziele

- Roadmap-, Goals-, Sprint-, Feature- oder Release-Artefakt-Innenleben festzulegen. Jedes davon gehört seiner eigenen Geschwister-Spec; diese Spec erklärt nur die Mission-seitige Oberfläche und die Querverweise, die sie trägt.
- `audience-identification` zu ersetzen. Audience-Aufzählung, -Charakterisierung und -Bestätigung gehören dorthin; diese Spec konsumiert das resultierende Artefakt und **DARF NICHT [MUST NOT]** Audiences inline erfinden.
- `continuous-improvement` zu ersetzen. Diese Spec führt ereignis- und kalendergetriebene Audits über die Prozess-Hygiene des gesamten Portfolios; Mission-seitiges Authoring ist Produkt-formgebend, nicht Prozess-formgebend, und die beiden Kadenzen laufen parallel ohne sich zu ersetzen.
- Eine Kalender-Deadline für die Mission-Erfüllung zu erzwingen. Hobby-Projekte tragen laut Geschwister-Specs `sprint` und `roadmap` keine Daten; diese Spec übernimmt diese Einschränkung und lehnt kalender-gebundene Time-bound-Klauseln ab.
- Portfolio-Strategiedokumente (Vision-Decks, OKR-Sheets, Product-Briefs) zu ersetzen. Die Mission-Datei ist ein Markdown-Artefakt unter Versionskontrolle neben dem Code, den sie beschreibt; Querverweise auf externe Dokumente sind erlaubt, aber niemals autoritativ.
- Ein Stakeholder-Sign-off-Ritual zu erzwingen, bevor Mission-Schreibvorgänge akzeptiert werden. Hobby-Projekte tragen keinen Stakeholder-Prozess; die Anforderungen Audience-Tailoring + Outcome-Verknüpfung + verifizierendes Feature ersetzen zusammen das, was ein Enterprise-Sign-off abfangen würde.

## Anforderungen

### Verzeichnislayout und Datei-Form

- **MUSS [MUST]** die Mission unter `project/mission.md` ablegen, genau eine Datei pro Projekt, niemals gesplittet.
- **DARF NICHT [MUST NOT]** die Datei unter `docs/` oder einem anderen Unterverzeichnis verschachteln; die Mission ist ein Top-Level-Orientierungspunkt parallel zu `spec/`, `tests/` und den übrigen `project/`-Planungsartefakten.
- **KANN [MAY]** in Repositories fehlen, die das Planungs-Toolset noch nicht eingeführt haben; Abwesenheit ist laut Geschwister-Spec `project-structure` zulässig. Sobald die Datei existiert, gilt jede Anforderung dieser Spec.

### Frontmatter-Schema

- **MUSS [MUST]** die Datei mit einem YAML-Frontmatter-Fence öffnen, der folgende Felder in dieser Reihenfolge trägt:
  - `mission_statement` (String, verpflichtend, nicht leer) — der eigentliche SMART-konforme Satz in der Hauptsprache des Projekts; ein Satz, keine Markdown-Formatierung über Inline-Interpunktion hinaus.
  - `relevant_outcomes` (Liste von Outcome-IDs, verpflichtend, nicht leer) — jeder Eintrag **MUSS [MUST]** ein in `project/goals.md` definiertes `O-<n>` matchen, laut Geschwister-Spec `roadmap`.
  - `audiences` (Liste von Audience-Bezeichnern, verpflichtend, nicht leer) — jeder Eintrag **MUSS [MUST]** zu einem Audience-Eintrag im Audience-Artefakt des Projekts matchen (`AUDIENCES.md` oder die laut `audience-identification` vom konsumierenden Repo deklarierte Stelle).
  - `verifies_via` (String, verpflichtend) — Muster `<feature-id>:acceptance-<n>` (zum Beispiel `F-3:acceptance-2`), benennt das Feature, dessen Frontmatter-Feld `verifies_sprint_value` auf das Akzeptanzkriterium zeigt, das die Erfüllung der Mission belegt; das genannte Feature **MUSS [MUST]** unter `project/features/` existieren und der genannte Akzeptanz-Identifier **MUSS [MUST]** auf diesem Feature existieren.
  - `time_bound` (Objekt, verpflichtend) — eine von zwei Formen: `{ kind: outcome, ref: O-<n> }` (Time-bound an ein bestimmtes Outcome aus `goals.md`) oder `{ kind: mvp_completion }` (Time-bound an den Moment, in dem `mvp_status` `achieved` erreicht); kalender-gebundene Formen sind verboten.
  - `mvp_status` (Enum, verpflichtend) — einer von `defining` (der MVP-Scope wird gerade geformt), `in_progress` (mindestens ein MVP-Item ist `active` oder `done`), `achieved` (jedes MVP-Item ist `done` und das verifizierende Akzeptanzkriterium ist abgehakt), `stabilised` (der Zustand `achieved` hat über einen vollen Folgesprint laut §Stabilisierungs-Gate gehalten).
  - `created` (ISO-Datum, verpflichtend) — Datum, an dem die Mission-Datei erstmals geschrieben wurde; nach Erstellung nie editiert.
  - `revised_at` (ISO-Datum oder null, verpflichtend) — Datum der jüngsten substantiellen Revision (Änderung des Statements, der Audiences, der Verifikation oder der Time-bound-Klausel); null, solange die Mission-Datei im Original-Schreibstand ist.
- **DARF NICHT [MUST NOT]** Kalender-Deadlines, OKR-Werte, KPI-Felder oder Stakeholder-Zuweisungs-Felder über die oben deklarierten hinaus enthalten; Lints flaggen unbekannte Schlüsselwörter.

### Body-Sections

- **MUSS [MUST]** folgende Level-2-Sections in dieser Reihenfolge tragen, auch wenn der Inhalt knapp ist (Skills hängen an stabilen Section-Überschriften):
  - `## Statement` — das Mission Statement als Prosa wiederholt, unmittelbar gefolgt von einer SMART-Aufschlüsselung (ein kurzer Absatz pro Buchstabe, der benennt, welches Frontmatter-Feld diesen Buchstaben verankert — siehe §SMART-Vertrag).
  - `## Audiences` — ein Absatz pro Audience aus dem Frontmatter-Feld `audiences`, der die Audience benennt und beschreibt, was das MVP dieser Audience konkret liefert; keine Audience darf im Frontmatter ohne zugehörigen Absatz hier auftauchen, und kein Absatz darf eine Audience nennen, die nicht im Frontmatter steht.
  - `## Verification` — ein kurzer Prosa-Verweis auf das Feature und Akzeptanzkriterium aus `verifies_via`, mit Wiederholung des Kriterium-Texts wortgetreu, damit die Mission-Datei lesbar bleibt, ohne den Feature-Bestand durchzugehen.
  - `## Source` — der Audit-Trail: welches Audience-Artefakt konsultiert wurde (Pfad plus Last-Commit-SHA zum Schreibzeitpunkt), welche `goals.md`-Outcomes referenziert wurden, wer oder was die Mission verfasst hat (Operator-Name, Skill-Version oder Commit-SHA der mission-erzeugenden Änderung).
- **KANN [MAY]** eine zusätzliche `## Open questions`-Section für offene Authoring-Entscheidungen tragen; **DARF NICHT [MUST NOT]** die Reihenfolge der vier Pflicht-Sections wegen optionaler ändern.

### SMART-Vertrag

Das Mission Statement **MUSS [MUST]** jede der folgenden fünf Bedingungen erfüllen, einzeln gegen die genannten Artefakte prüfbar:

- **Specific** — das `mission_statement` benennt sowohl **was** das Projekt tut als auch **für wen**; das **für wen** **MUSS [MUST]** auf einen oder mehrere Einträge in der Frontmatter-Liste `audiences` auflösen. Eine Mission, deren Audience implizit ist („für Nutzer"), schlägt diese Bedingung; der Audience-Bezeichner ist explizit.
- **Measurable** — das Frontmatter-Feld `verifies_via` benennt genau ein Feature und genau ein Akzeptanzkriterium auf diesem Feature. Sobald dieses Akzeptanzkriterium abgehakt ist (laut Geschwister-Spec `feature`), ist die Mission messbar erfüllt. Kein anderer Verifikations-Mechanismus wird eingeführt.
- **Achievable** — jedes Roadmap-Item mit `mvp: true` trägt `detail: fine` und ein nicht-null `target_sprint` laut Geschwister-Spec `roadmap`, und die Anzahl der MVP-Items **SOLLTE [SHOULD]** grob der Kapazität von zwei bis fünf Sprints entsprechen. Ein unbegrenzter MVP-Scope (jedes Roadmap-Item mit `mvp: true` geflaggt) hebelt die Erreichbarkeit aus und **MUSS [MUST]** von konsumierenden Skills mit einem wortgetreuen Fehler abgelehnt werden.
- **Relevant** — die Frontmatter-Liste `relevant_outcomes` ist nicht leer und jeder Eintrag löst auf ein Outcome in `project/goals.md` auf. Eine Mission, die nicht auf mindestens ein deklariertes Outcome zurückbindet, schlägt diese Bedingung.
- **Time-bound** — das Frontmatter-Objekt `time_bound` ist eines von `{ kind: outcome, ref: O-<n> }` oder `{ kind: mvp_completion }`. Kalenderdaten und Freitext-Deadlines werden abgelehnt. Die Bindung ist absichtlich outcome-förmig, weil Hobby-Sprint-Dauer laut Geschwister-Spec `sprint` variabel ist; diese Spec übernimmt diese Einschränkung.

### MVP-Definition und -Abgrenzung

- **MUSS [MUST]** das MVP als die Menge der Roadmap-Items in `project/roadmap.md` definieren, deren YAML-Block `mvp: true` trägt. Der autoritative Ort des Flags ist die Roadmap; die Mission-Spec ist die Autorität für die Semantik des Flags.
- **MUSS [MUST]** jedes Roadmap-Item mit `mvp: false` als **Post-MVP** behandeln und damit als optional für die Mission-Erfüllung. Post-MVP-Items bleiben explizit in der Roadmap, damit die Grenze zwischen Minimum und zusätzlichem Scope sichtbar bleibt — ein Item zu benennen, aber mit `mvp: false` zu flaggen, ist die kanonische Art zu sagen „wir wissen davon, es ist nicht Teil des MVP, es wartet".
- **MUSS [MUST]** für jedes Roadmap-Item mit `mvp: true` verlangen, dass mindestens eines seiner Features (laut Geschwister-Spec `feature`) `verifies_sprint_value` nicht-null deklariert, sobald dieses Feature im MVP-abschließenden Sprint ausgeliefert wird. Über den gesamten MVP-Scope hinweg **MUSS [MUST]** genau ein Feature dasjenige sein, das im `verifies_via`-Feld der Mission benannt ist; dieses Feature ist das **mission-verifizierende Feature**.
- **DARF NICHT [MUST NOT]** zulassen, dass ein Roadmap-Item sein `mvp`-Flag von `true` auf `false` umschaltet, nachdem das Item `status: active` erreicht hat; sobald ein Item in die MVP-Ausführung tritt, ist das nachträgliche Entfernen aus dem MVP-Scope verboten, weil es die Erreichbarkeits-Schranke des SMART-Vertrags brechen würde. Items **KÖNNEN [MAY]** vor der Stabilisierung jederzeit von `mvp: false` auf `mvp: true` umschalten.

### Stabilisierungs-Gate

- **MUSS [MUST]** das MVP genau dann als **stabilisiert** behandeln, wenn jede der folgenden Bedingungen gleichzeitig erfüllt ist:
  - jedes Roadmap-Item mit `mvp: true` trägt `status: done`;
  - der Sprint, der das letzte MVP-Item geschlossen hat, ist selbst laut Geschwister-Spec `sprint` `status: closed`;
  - ein voller Folgesprint hat `status: closed` erreicht (oder `cancelled` aus MVP-fremden Gründen), ohne dass ein MVP-Item auf `status: active` zurückgekehrt ist;
  - keine Defekt-Fix-Arbeit, die ein MVP-Item betrifft, ist laut Geschwister-Spec `feature` aktuell in `status: in_progress`.
- **DARF NICHT [MUST NOT]** zulassen, dass ein Post-MVP-Roadmap-Item (`mvp: false`) `proposed → active` übergeht, solange `mvp_status` einer von `defining`, `in_progress` oder `achieved` ist. Der Übergang ist nur zulässig, wenn `mvp_status: stabilised`.
- **MUSS [MUST]** verlangen, dass der Operator (oder ein zukünftiger Automations-Skill) `mvp_status` explizit auf `stabilised` umlegt; das Umlegen **DARF NICHT [MUST NOT]** still aus der Erfüllung der obigen Bedingungen abgeleitet werden. Der Schalter-Akt protokolliert die Entscheidung; die Bedingungen rechtfertigen sie.
- **MUSS [MUST]** `mvp_status: stabilised → in_progress` zurücksetzen, sobald ein MVP-Item auf `status: active` zurückgeht (zum Beispiel weil ein Defekt nach der Stabilisierung auftaucht); das Gate greift dann erneut, und Post-MVP-Items, die zum Zeitpunkt der Rücksetzung bereits in `status: active` sind, **KÖNNEN [MAY]** zu Ende geführt werden, aber kein neues Post-MVP-Item **DARF [MUST]** gestartet werden, bevor die Stabilisierung wiederhergestellt ist.
- **KANN [MAY]** die Stabilisierungs-Belege (die Sprint-Nummer, die die Bedingung „ein voller Folgesprint" erfüllt hat, das Datum der Operator-Entscheidung) für den Audit-Trail in `## Source` festhalten.

### Audience-Tailoring

- **MUSS [MUST]** für jede Audience in `audiences` einen Absatz in `## Audiences` verlangen, der den Audience-Bezeichner benennt und beschreibt, was das MVP dieser Audience konkret liefert. Eine reine Liste von Audience-Namen ohne zugehörige Absätze schlägt die Validierung.
- **DARF NICHT [MUST NOT]** in `## Audiences` eine Audience nennen, die nicht auch in der Frontmatter-Liste `audiences` steht, und umgekehrt; die beiden Oberflächen werden bidirektional validiert.
- **SOLLTE [SHOULD]** jeden Per-Audience-Absatz kurz halten (drei bis fünf Sätze); braucht eine einzelne Audience mehr, ist die Audience selbst wahrscheinlich unter-spezifiziert, und `audience-identification` sollte erneut laufen, statt die Mission-Datei zu strecken.
- **KANN [MAY]** Audiences gruppieren, wenn deren MVP-Lieferumfang identisch ist (ein Absatz, der die zwei Audiences benennt und den geteilten Lieferumfang beschreibt), aber jeder Audience-Bezeichner **MUSS [MUST]** trotzdem namentlich erscheinen, und die Gruppierungs-Begründung **MUSS [MUST]** in demselben Absatz stehen.

### Cross-Spec-Verknüpfung

- **MUSS [MUST]** `audience-identification` als Autorität für Form und Inhalt des Audience-Artefakts behandeln. Hat das Projekt kein Audience-Artefakt, ist Mission-Authoring blockiert; der Skill `audience-identify` **MUSS [MUST]** zuerst dispatched werden, identisch zur Regel, die heute schon für Outcome-Authoring in der Geschwister-Spec `roadmap` gilt.
- **MUSS [MUST]** die Geschwister-Spec `roadmap` als Autorität für den Ort des `mvp`-Felds im Roadmap-Item-YAML-Schema behandeln; diese Spec ist die Autorität für die Semantik des Felds. Die beiden Oberflächen verweisen explizit aufeinander, und der Querverweis ist pro Belang einseitig (Ort → roadmap, Semantik → mission).
- **MUSS [MUST]** die Geschwister-Spec `feature` als Autorität für `verifies_sprint_value` behandeln; diese Spec konsumiert den Mechanismus und **DARF NICHT [MUST NOT]** ihn neu definieren.
- **MUSS [MUST]** `goals.md` (geregelt von `roadmap`) als Autorität für Outcome-IDs behandeln; diese Spec verweist nur auf sie.

### Hobby-Skala-Varianz

- **DARF NICHT [MUST NOT]** Aufwandsschätzungen, Kalender-Deadlines, Velocity-Metriken oder Stakeholder-Sign-off-Felder an der Mission-Datei verlangen; der oben festgelegte SMART-Vertrag ersetzt bereits, was diese in einem Enterprise-Kontext abfangen würden.
- **SOLLTE [SHOULD]** lange Strecken zwischen Mission-Revision und MVP-Erfüllung tolerieren; ein unverändertes `mission_statement` ist der korrekte Zustand, solange die Mission noch beschreibt, was das Projekt tut.
- **KANN [MAY]** das Mission Statement jederzeit vor `mvp_status: stabilised` revidieren; Revisionen nach der Stabilisierung **MÜSSEN [MUST]** eine ein-absätzige Begründung in `## Source` tragen, weil sie umdeuten, wofür das stabilisierte MVP gut war.

## Akzeptanzkriterien

- [ ] `project/mission.md` existiert im Repo-Root jedes adoptierenden Projekts; verschachtelte oder alternative Orte schlagen die Validierung.
- [ ] Das Mission-Frontmatter trägt die acht verpflichtenden Felder (`mission_statement`, `relevant_outcomes`, `audiences`, `verifies_via`, `time_bound`, `mvp_status`, `created`, `revised_at`) in der festgelegten Reihenfolge; Lints flaggen unbekannte Schlüsselwörter und lehnen jedes Kalenderdatum-Deadline-Feld jenseits von `created` und `revised_at` ab.
- [ ] Der Mission-Body trägt die vier verpflichtenden Level-2-Sections (`Statement`, `Audiences`, `Verification`, `Source`) in der festgelegten Reihenfolge; fehlende Sections schlagen die Validierung.
- [ ] Jede Audience in `audiences` löst auf einen Eintrag im Audience-Artefakt des Projekts auf und hat einen zugeschnittenen Absatz in `## Audiences`; reine Audience-Listen oder verwaiste Absätze schlagen die Validierung.
- [ ] Jedes Outcome in `relevant_outcomes` löst auf ein `O-<n>` in `project/goals.md` auf; eine leere Liste oder ein nicht auflösender Eintrag schlägt die Validierung.
- [ ] `verifies_via` löst auf eine Feature-Datei unter `project/features/` auf, deren Frontmatter `verifies_sprint_value` mit dem benannten Akzeptanz-Identifier deklariert; gebrochene Referenzen schlagen die Validierung.
- [ ] `time_bound` ist eine von `{ kind: outcome, ref: O-<n> }` oder `{ kind: mvp_completion }`; jede andere Form schlägt die Validierung, und Kalenderdatum-Formen werden mit einem wortgetreuen Fehler abgelehnt.
- [ ] Kein Post-MVP-Roadmap-Item (`mvp: false`) ist in `status: active`, solange `mvp_status` einer von `defining`, `in_progress` oder `achieved` ist; der konsumierende Skill lehnt den Übergang mit einem wortgetreuen Fehler ab, der diese Spec zitiert.
- [ ] Jedes Roadmap-Item mit `mvp: true` trägt `detail: fine` und ein nicht-null `target_sprint`; Lints schlagen sonst fehl.
- [ ] Kein Roadmap-Item kippt sein `mvp`-Flag von `true` auf `false`, nachdem es `status: active` erreicht hat; die umgekehrte Richtung (`false → true`) ist nur vor der Stabilisierung erlaubt.
- [ ] `mvp_status` übergeht nur entlang des legalen Pfads `defining → in_progress → achieved → stabilised`, mit dem Rückweg `stabilised → in_progress`, sobald ein MVP-Item zurückgeht; jeder andere Übergang schlägt die Validierung.
- [ ] Wenn `mvp_status: stabilised`, ist jedes Roadmap-Item mit `mvp: true` in `status: done`, und ein voller Folgesprint hat geschlossen, ohne dass ein MVP-Item zurückgegangen ist; der konsumierende Skill verifiziert die Bedingungen, bevor er den Operator-Schalter akzeptiert.
- [ ] `audience-identification` wird vor dem Mission-Authoring auf einem frischen Repo ohne Audience-Artefakt ausgelöst; fehlende Audiences blockieren Mission-Schreibvorgänge genauso, wie sie laut Geschwister-Spec `roadmap` Outcome-Schreibvorgänge blockieren.
- [ ] Keine Mission-Revision nach `mvp_status: stabilised` ohne einen ein-absätzigen Begründungs-Block in `## Source`; fehlende Begründung schlägt die Validierung.

## Offene Fragen

- Soll das Feld `verifies_via` irgendwann mehrere Feature-plus-Kriterium-Paare zulassen (eine Liste statt eines einzelnen Strings), damit zusammengesetzte Missionen, deren Verifikation tatsächlich auf zwei Features fällt, ausdrückbar bleiben? Default: `verifies_via` als einzelnen String `<feature-id>:acceptance-<n>` belassen (die eigene `project/mission.md` dieses Repos hat einen vollständigen Zyklus `defining → in_progress → achieved → stabilised` auf einem einzigen Paar durchlaufen, der Single-Pair-Default ist also validiert, nicht bloß hypothetisch). Revisitieren, wenn: eine reale `project/mission.md` verfasst wird, deren MVP-Scope Roadmap-Items umspannt, die tatsächlich in unterschiedlichen Sprints schließen, sodass kein einzelner Sprint das eine wert-verifizierende Feature tragen kann, UND der Operator zeigen kann, dass sich der Wert nicht auf ein Akzeptanzkriterium kollabieren lässt — konkret, wenn ein `mission-define`- oder `mission-revise`-Lauf blockiert wird, weil zwei verschiedene `verifies_sprint_value`-Features in zwei verschiedenen geschlossenen Sprints beide für dieselbe Mission tragend sind.
- Soll die Bedingung „ein voller Folgesprint" im Stabilisierungs-Gate pro Projekt konfigurierbar sein (manche Projekte wollen vielleicht zwei)? Default: die feste Konstante von einem vollen Folgesprint belassen und kein Feld `stabilisation_soak_sprints` hinzufügen (Sprint 0002 dieses Repos hat den Soak für das in Sprint 0001 geschlossene MVP ohne Regression erfüllt, der Default hat also positive Nutzungsdaten hinter sich). Revisitieren, wenn: eine reale `project/mission.md` eine Post-Stabilisierungs-Regression zeigt, die ein einzelner Folge-Soak-Sprint nachweislich nicht abgefangen hat — ein MVP-Item, das im zweiten Post-MVP-Sprint nach dem Umlegen auf `stabilised` auf `status: active` zurückgeht — und damit belegt, dass ein Sprint für dieses Projekt zu kurz war.
- Soll der Rückweg `mvp_status: stabilised → in_progress` automatisch jedes Post-MVP-Item, das bereits in `status: active` ist, anhalten, oder nur neue Starts blockieren? Default: die weichere Regel aus §Stabilisierungs-Gate belassen — ein Rückweg blockiert neue Post-MVP-Starts, lässt aber Post-MVP-Items im Flug zu Ende laufen, ohne Automation, die aktive Items zwangsweise anhält. Revisitieren, wenn: ein realer Post-Stabilisierungs-Rückweg auftritt (`stabilised → in_progress` in irgendeiner `project/mission.md` §Source protokolliert) UND eine Defekt-Postmortem zeigt, dass das Zu-Ende-laufen-Lassen eines Post-MVP-Items im Flug während des Rückwegs die Regression maskiert oder verstärkt hat. Bisher wurde im Portfolio kein Rückweg beobachtet.
- Soll die Spec irgendwann einen maschinen-lesbaren Mission-Coverage-Report tragen (welche Audiences das MVP bedient, mit Verifikations-Status pro Audience)? Default: den Report weiter verschieben und ihn, wenn er kommt, als generiertes Artefakt statt als verfasstes Frontmatter bauen (die Bedingung „mindestens ein Projekt hat einen vollen Mission-Zyklus durchlaufen" ist bereits erfüllt, die Verschiebung ruht also allein auf dem fehlenden nachgelagerten Konsumenten). Revisitieren, wenn: ein benannter nachgelagerter Konsument Per-Audience-MVP-Verifikations-Status verlangt, der an die Mission statt an das Release-Audience-Artefakt gekoppelt ist — konkret, wenn die Subsection `## Audiences served` von `release-skill-layer` Skill A oder ein zukünftiger `audience-doc-author`-Schritt geändert wird, um `## Audiences` und `verifies_via` aus `project/mission.md` für den Per-Audience-Verifikations-Status zu lesen. Heute konsumiert keine Spec die Mission für Coverage; `release-skill-layer` mappt Audiences aus dem Release-Audience-Artefakt, nicht aus der Mission.
