# Zielgruppen-Identifikation

Status: draft

## Kontext
<!-- Warum existiert diese Spec? Welches Problem, welcher Bedarf oder welche Einschränkung treibt sie? -->

Software-Module und Projekte werden von mehreren Zielgruppen konsumiert, betrieben, eingeschränkt oder beobachtet — Nutzer, Betreiber, nachgelagerte Integratoren, Maintainer, Security, Compliance, Business-Stakeholder, indirekt betroffene Endnutzer und mehr. Ohne ein diszipliniertes Verfahren, die zutreffenden Zielgruppen für einen *abgesteckten Kontext* (ein konkretes Modul, einen Service, eine Bibliothek oder ein Projekt) zu ermitteln, werden Entscheidungen über Dokumentationstiefe, API-Oberfläche, Release-Taktung, SLAs und Sicherheitslage gegen die privaten Annahmen der Autoren statt gegen die tatsächliche Zielgruppen-Menge getroffen. Diese Spec definiert ein wiederholbares Verfahren, mit dem sich die Zielgruppen eines abgesteckten Kontexts ermitteln und charakterisieren lassen, damit nachgelagerte Artefakte (READMEs, Specs, Threat Models, Release Notes, SLAs) auf eine belastbare Zielgruppenliste verweisen können, statt sie jedes Mal neu zu erfinden.

## Ziele
<!-- Was diese Spec erreichen will. Stichpunkte, ergebnisorientiert. -->
- Ein konsistentes Verfahren zum Aufzählen der Zielgruppen eines abgesteckten Kontexts bereitstellen
- Sicherstellen, dass jede identifizierte Zielgruppe über ihre Beziehung zum Kontext charakterisiert wird (konsumieren, betreiben, erweitern, regeln, …)
- Ein Artefakt erzeugen, auf das andere Specs (`readme-structure`, `pull-request-workflow`, künftige Threat-Modeling-Specs, …) verweisen können
- Zielgruppen-Identifikation wiederholbar und reviewbar machen — nicht das Bauchgefühl einzelner Autoren
- Unbekannte oder angenommene Zielgruppen explizit sichtbar machen, damit sie validiert oder verworfen werden können

## Nicht-Ziele
<!-- Was explizit außerhalb des Scopes liegt. Verhindert Scope Creep. -->
- Definition von Marketing-Personas oder demografischer Segmentierung
- Vorgaben, wie mit identifizierten Zielgruppen kommuniziert wird
- Erzeugen einer dauerhaften, organisationsweiten Master-Zielgruppenliste (diese Spec gilt pro Kontext, nicht pro Organisation)
- Threat Modeling — Zielgruppen fließen dort ein, sind aber nicht mit Angreifern gleichzusetzen
- Vorschreiben eines einzigen Artefakt-Formats für jeden Kontext. Der kanonische Default für einen eigenständigen bounded context ist `AUDIENCES.md` an dessen Wurzel (siehe Anforderungen §Artefakt-Ort), aber kleine oder Sub-Modul-Kontexte **DÜRFEN** die Liste in einen README-Abschnitt oder einen ADR einbetten; diese Spec ratifiziert den Default, verbietet die Alternativen aber nicht

## Anforderungen
<!-- RFC-2119-Schlüsselwörter verwenden: MUST, SHOULD, MAY. Eine atomare Anforderung pro Bullet. -->
- **MUSS [MUST]** mit einer schriftlichen Deklaration des abgesteckten Kontexts beginnen: was das Modul oder Projekt *ist*, wo seine Grenzen verlaufen und was explizit außerhalb liegt
- **MUSS [MUST]** Zielgruppen unter folgenden Beziehungskategorien aufzählen und "keine" mit Begründung angeben, wenn eine Kategorie nicht zutrifft:
  - **Direkte Konsumenten** — wer die Schnittstelle des Kontexts aufruft (Menschen, andere Services, nachgelagerte Bibliotheken)
  - **Betreiber** — wer den Kontext in Produktion oder Test ausführt, deployt, überwacht oder hostet
  - **Beitragende / Maintainer** — wer den Code oder dessen Inhalte ändert
  - **Steuernde Parteien** — Legal, Compliance, Security, Architektur-Review, Business-Stakeholder mit Freigabe- oder Vorgabebefugnis
  - **Indirekte Zielgruppen** — Parteien, die vom Kontext betroffen sind, ohne direkt mit ihm zu interagieren (z. B. Endnutzer hinter einem konsumierten Service)
- **MUSS [MUST]** pro gelisteter Zielgruppe erfassen:
  - kurzes Label
  - Beziehungskategorie
  - Interaktionsfläche (API, CLI, Config, Docs, Dashboard, Incident-Kanal, …)
  - was die Zielgruppe vom Kontext erwartet oder benötigt
  - die Dokumentations-`track`, auf die die Zielgruppe abbildet (einer aus `user-docs` oder `developer-docs`, gemäß `spec/project/docs-audience-tracks/` §Audience-zu-Spur-Mapping); der Portfolio-Basis-Default (`user` → `user-docs`; `contributor` / `operator` / `release-manager` → `developer-docs`) ist der Ausgangspunkt und pro Projekt mit dokumentierter Einzeiler-Begründung übersteuerbar
  - offene Fragen oder Annahmen, wenn Informationen fehlen
- **MUSS [MUST]** jede Zielgruppe als `confirmed` (mit realer Vertretung oder belastbarer Quelle validiert) oder `assumed` (vom Autor angenommen) kennzeichnen
- **MUSS [MUST]** die Zielgruppenliste erzeugen, bevor nachgelagerte Artefakte geschrieben werden, die eine Zielgruppe beanspruchen (READMEs, Specs, Threat Models, Release Notes, SLAs, Dokumentations-Spuren gemäß `spec/project/docs-audience-tracks/`, …), damit diese darauf verweisen statt sie neu zu formulieren; das Documentation-Tracks-Artefakt ist einer der nachgelagerten Konsumenten und das Per-Audience-`track`-Feld ist die konsumierende Oberfläche
- **MUSS [MUST]** diese Spec portfolioweit anwenden: jedes Repository, das ein zielgruppen-beanspruchendes nachgelagertes Artefakt produziert (README, Mission, Roadmap, Docs-Spuren, Release Notes, SLAs), MUSS ein Zielgruppen-Artefakt besitzen. Es gibt kein Opt-in oder Opt-out pro Repository; ein Opt-out ist nur pro Beziehungskategorie möglich („keine" mit Begründung dokumentieren). Das *Format* des Artefakts skaliert mit der Kontextgröße (siehe §Artefakt-Ort), das Verfahren selbst wird jedoch nie übersprungen
- **SOLLTE [SHOULD]** Zielgruppen nach Kritikalität für den Erfolg des Kontexts ordnen (primär / sekundär / peripher)
- **SOLLTE [SHOULD]** das Zielgruppen-Artefakt unter `AUDIENCES.md` an der Wurzel des bounded context als kanonischen Default ablegen; für kleine Module oder Sub-Kontexte, in denen eine eigenständige Datei überdimensioniert ist, sind ein README-Abschnitt („## Zielgruppen" oder „## Intended consumers") oder ein ADR akzeptable Alternativen. An welchem Ort auch immer das Artefakt liegt, es lebt **neben** dem Kontext, den es beschreibt — nicht in einem zentralen Register —, damit konsumierende Specs (zum Beispiel `mission`, `roadmap`, `release-notes-audience-analysis`, `release-skill-layer` und Tooling wie `github-issue-templates-apply`) es deterministisch finden können; die Liste ist nicht abschließend, und `spec-drift-audit` ist der kanonische Detektor für neu hinzukommende Konsumenten, die das Artefakt zitieren. Es gibt keine minimale Größe, unterhalb der das Verfahren übersprungen wird; für Kontexte, die zu klein für ein eigenes Artefakt sind, wird die Zielgruppenliste in das Artefakt des übergeordneten Kontexts oder in einen README-Abschnitt eingefaltet. Das Format skaliert mit der Größe, das Verfahren nicht
- **SOLLTE [SHOULD]** die Zielgruppenliste erneut prüfen, sobald sich der Scope des Kontexts wesentlich ändert — neue öffentliche API, neues Deployment-Target, neue regulierte Datenklasse, neuer Stakeholder
- **SOLLTE [SHOULD]** das Zielgruppen-Artefakt über die Git-Historie des Repositories versionieren; es gibt kein separates Versionsfeld und keinen Per-Release-Snapshot. Die Revisions-Taktung ist ereignisgesteuert gemäß dem §Revisit-Trigger-Bullet oben, und `spec-drift-audit` erkennt, wenn das Artefakt von der tatsächlichen Interaktionsfläche abgedriftet ist
- **KANN [MAY]** jeden Zielgruppen-Eintrag auf die für ihn erzeugten Specs, Docs oder SLAs verlinken, damit Abdeckung sichtbar wird
- **KANN [MAY]** Zielgruppen zusätzlich nach Geografie, Organisationseinheit oder Mandantenzuordnung unterteilen, wenn solche Unterschiede das erwartete Liefergut verändern

## Abnahmekriterien
<!-- Testbare, abhakbare Bedingungen. Reviewer müssen pro Punkt "erfüllt / nicht erfüllt" markieren können. -->
- [ ] Ein durchgearbeitetes Beispiel existiert, das das Verfahren auf ein konkretes Artefakt dieses Repositories anwendet (z. B. das `nolte-shared`-Plugin oder einen seiner Skills)
- [ ] Die `readme-structure`-Spec verweist auf diese Spec an der Stelle, an der sie von "intended consumers" spricht
- [ ] Eine nach dieser Spec erzeugte Zielgruppenliste enthält mindestens eine Zielgruppe pro zutreffender Beziehungskategorie oder dokumentiert "keine" mit Begründung für jede ausgelassene Kategorie
- [ ] Jeder Zielgruppen-Eintrag unterscheidet `confirmed` von `assumed`
- [ ] Jeder Zielgruppen-Eintrag trägt ein `track`-Feld, dessen Wert `user-docs` oder `developer-docs` ist (oder ein Erweiterungs-Wert, den eine projekt-typ-spezifische Spec deklariert); der Portfolio-Basis-Default wird angewendet, sofern keine Einzeiler-Override-Begründung inline festgehalten ist
- [ ] Der abgesteckte Kontext ist schriftlich deklariert, bevor eine Zielgruppe gelistet wird
- [ ] Der `spec-drift-audit`-Skill kann ein Modul flaggen, dessen dokumentierte Zielgruppen nicht mehr mit der tatsächlichen Interaktionsfläche übereinstimmen
- [ ] Jeder eigenständige bounded context, der ein Zielgruppen-Artefakt produziert hat, liefert es als `AUDIENCES.md` an der Kontext-Wurzel aus ODER der gewählte Alternativ-Ort (ein README-Abschnitt „## Zielgruppen" / „## Intended consumers" oder ein ADR) ist durch die geringe Kontextgröße oder vorhandene Repo-Präzedenz gerechtfertigt. Verifizierbar durch `find . -name AUDIENCES.md -not -path './node_modules/*' -not -path './.venv/*'` plus einen grep der README-Dateien nach den Abschnitts-Überschriften

## Offene Fragen
<!-- Ungelöste Entscheidungen, bekannte Unbekannte, Punkte, die eine Stakeholder-Antwort brauchen. -->
- Wie verhält sich diese Spec zu künftigen Threat-Modeling-, Privacy-Impact- oder SLA-Specs, die dieselbe Zielgruppenliste konsumieren werden? Freischalten, sobald die erste Spec auf der Security-/Privacy-/SLA-Achse, die das Zielgruppen-Artefakt konsumiert, unter `spec/project/` entworfen wird (zum Beispiel `spec/project/threat-modeling/`, `spec/project/privacy-impact/` oder `spec/project/sla/`, deren Anforderungen das Zielgruppen-Artefakt zitieren). Messbar: `grep -rl 'audience' spec/project/{threat-modeling,privacy-impact,sla}/` liefert einen Treffer. Dann den konkreten bidirektionalen Querverweis verdrahten; die `spec-drift-audit`-Klausel „neu hinzukommende Konsumenten, die das Artefakt zitieren" (siehe die §Artefakt-Ort-Anforderung) macht die Abhängigkeit sichtbar. Kein externer Upstream-Link betroffen — dies ist ein internes Portfolio-Authoring-Ereignis, keine Abhängigkeit von der Claude-Code-Plattform.
