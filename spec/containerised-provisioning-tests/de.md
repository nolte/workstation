# Containerisierte Provisionierungstests

Status: draft

## Kontext

Dieses Repository ist ein [chezmoi](https://www.chezmoi.io/)-Quellbaum, der Entwickler-Workstations provisioniert. Das eigentliche „Build-Artefakt" ist der Zustand, den `chezmoi init --apply https://github.com/nolte/workstation.git` auf einer Zielmaschine herstellt: eine befüllte `~/.tool-versions` mit asdf-verwalteten CLIs, getemplatete Dotfiles (`~/.gitconfig`, `~/taskfile.yaml`), zwei Python-Virtualenvs unter `~/.venvs/`, drei zsh-Plugins unter `~/.oh-my-zsh/custom/plugins/` und ein Checkout der geteilten Taskfile-Collection unter `~/.local/share/taskfile-collection/`.

Die bestehende CI-Pipeline (`.github/workflows/build-static-tests.yaml`) deckt Prosa-Linting (Vale), pre-commit, Trivy und chain-bench ab. Keiner dieser Jobs übt den eigentlichen Provisionierungspfad aus — sie validieren die *Quellen*, nicht das *Ergebnis*. Dadurch können heute drei Klassen von Regressionen unbemerkt auf `develop` landen:

- Eine in `chezmoi_config/dot_tool-versions` gebumpte Tool-Version hat kein funktionierendes asdf-Plugin oder kein passendes Release-Artefakt mehr.
- Eine Änderung an einem der `run_onchange_*`-Skripte bricht die Installation auf einer frischen Maschine, obwohl die gerenderte Datei `check-yaml` noch besteht.
- Eine Änderung an `.chezmoiexternal.toml` referenziert ein umgezogenes oder umbenanntes Upstream-Repo und bricht damit Neu-Bootstraps, ohne Maschinen zu beeinflussen, die das External bereits gecached haben.

Da der einzig sichere Ort, das durchgehend zu üben, eine Wegwerf-Umgebung ist, MUSS der Testpfad in einem Container leben. Der Container ist die Grenze, die das `$HOME` der Entwickler-Maschine und das User-FS des GitHub-Runners davor schützt, von einem ausschließlich als Test gedachten chezmoi-Lauf verändert zu werden.

## Ziele

- Verifizieren, dass `chezmoi apply` gegen den Inhalt dieses Repos auf einer sauberen Linux-Umgebung den erwarteten On-Disk-Zustand erzeugt — nicht nur, dass die Templates rendern.
- Die Verifikation automatisch laufen lassen bei jeder Änderung, die den Provisionierungspfad plausibel beeinflussen kann (push/PR auf `develop`, push auf `main`).
- Upstream-Drift (asdf-Plugins, Release-Artefakte, externe Repos) in fester wöchentlicher Kadenz erkennen, ohne dass Code-Änderungen nötig sind.
- Der Entwicklerin dieselbe Verifikation lokal über einen einzigen `task`-Aufruf bereitstellen, ohne zusätzliche Einrichtung jenseits einer vorhandenen Docker-Installation.
- Alle Nebenwirkungen eines Testlaufs innerhalb des Containers halten; nichts auf Host oder Runner wird verändert.
- Idempotenz nachweisen: Ein zweites `chezmoi apply` auf einem bereits provisionierten Stand MUSS ein No-Op sein.

## Nicht-Ziele

- Verifikation der macOS-Provisionierung. Das Repo ist heute Linux-fokussiert; ein macOS-Pfad bräuchte eine eigene Spec und einen Nicht-Container-Runner.
- Performance-, Durchsatz- oder Wall-Clock-Benchmarks des Apply-Vorgangs.
- Verifikation der *Inhalte* der `nolte/taskfiles`-Collection, die `.chezmoiexternal.toml` klont. Dieses Repo besitzt seine eigenen Tests.
- Verifikation der Workflows `release-cd-deliver-docs.yml` oder `release-cd-refresh-master.yml`. Die betreffen Doc-Auslieferung und Release-Fast-Forward, nicht die Provisionierung.
- Konkrete Dockerfile-Inhalte, exakte Shell-Skripte oder Assertion-Tool-Entscheidungen vorzuschreiben. Diese Spec definiert das *Was* und die *Randbedingungen*; der Implementierungs-PR macht das konkret.
- `build-static-tests.yaml` ersetzen. Die neue Pipeline ist additiv — pre-commit, Vale, Trivy und chain-bench bleiben eigene Jobs.

## Anforderungen

- **MUSS [MUST]**
  - Die gesamte Testausführung MUSS in einem Container stattfinden, der aus einem in dieses Repo eingecheckten `Dockerfile` gebaut wird (Vorschlagspfad: `tests/Dockerfile`). Das Base-Image MUSS ein gepinntes Ubuntu-LTS-Tag (oder ein Digest) sein, und der Pin MUSS für Renovate erkennbar sein, damit er zusammen mit dem übrigen Toolchain-Stand gebumpt wird.
  - Der Container MUSS ausschließlich die minimal nötigen System-Voraussetzungen installieren, um `chezmoi`, `asdf` und `python` lauffähig zu machen. Jedes weitere in `chezmoi_config/dot_tool-versions` gelistete Tool MUSS *vom Provisionierungslauf selbst* installiert werden, nicht ins Image vorgebacken — sonst übte der Test gerade den Pfad nicht aus, den er zu prüfen vorgibt.
  - Der Test-Entrypoint MUSS `chezmoi init` gegen den lokalen Working-Tree dieses Repos ausführen (nicht gegen einen Remote-Clone von GitHub), damit die Änderungen eines PR getestet werden, bevor sie auf `develop` existieren.
  - Der Test-Entrypoint MUSS `chezmoi apply` einmal ausführen, die Nachbedingungen aus §„Provisionierungs-Nachbedingungen" prüfen, anschließend `chezmoi apply` ein *zweites* Mal ausführen und sichern, dass kein `run_onchange_*`-Skript erneut feuert und der Exit-Status null ist.
  - Die vom Container konsumierte `chezmoi.toml` MUSS eine Testfixture unter `tests/` mit Dummy-Werten für `git_email` und `git_name` sein. Der Container DARF die `~/.config/chezmoi/chezmoi.toml` von Host oder Runner NICHT lesen.
  - Der Container MUSS ohne `--privileged`, ohne Mount des Docker-Sockets und ohne Bind-Mount des Entwickler-`$HOME` oder irgendeines anderen User-Verzeichnisses außerhalb des Repo-Checkouts laufen. Das Repo-Checkout selbst KANN [MAY] read-only gemountet oder zur Build-Zeit per `COPY` ins Image gelegt werden, aber das `$HOME` im Container MUSS ein im Image frisch angelegtes Verzeichnis sein.
  - Die neue Pipeline MUSS unter `.github/workflows/` angesiedelt sein und auf push auf `develop`, push auf `main`, Pull Requests gegen `develop` sowie auf einem wöchentlichen Schedule entsprechend dem bestehenden Static-Tests-Cron (`cron: '16 0 * * 1'`) laufen.
  - Die Root-`Taskfile.yml` MUSS ein neues Target `test:container` bekommen, das *dasselbe* Image mit *demselben* Entrypoint baut und startet wie der Workflow. Lokale und CI-Läufe MÜSSEN sich diesen einen Code-Pfad teilen; eine Regression in einem MUSS sich ohne Anpassungen im anderen reproduzieren lassen.
  - Der Platzhalter `tests/.gitkeep` MUSS in demselben PR entfernt werden, der die echten Testartefakte unter `tests/` einführt.
  - Die Assertion-Schicht MUSS in [Bats](https://github.com/bats-core/bats-core) geschrieben sein. Jede `MUSS`-Nachbedingung aus §„Provisionierungs-Nachbedingungen" MUSS einem eigenen `@test`-Block entsprechen, damit Fehler einzeln pro Assertion gemeldet werden und nicht als ein einziger Shell-Exit. Die Bats-Version MUSS im Repo in einer für Renovate erkennbaren Form gepinnt sein (entweder als asdf-verwaltetes Plugin, das nur im Test-Image verwendet wird, oder als Distro-Paketversions-Pin im Dockerfile), damit die Test-Engine-Version im Gleichschritt mit der übrigen Toolchain gebumpt wird.
  - Fehlerklassen MÜSSEN unterscheidbar sein. Ein fehlgeschlagener `@test`-Block (Assertion: `asdf which kubectl` löst nicht auf, `~/.venvs/docs` fehlt) erscheint als Bats-Test-Fehlschlag mit einem Gesamt-Exit ungleich null und Per-Test-Diagnose; ein fehlgeschlagener Image-Build, ein Netzwerkfehler beim Ziehen eines asdf-Plugins oder ein chezmoi-Crash im Entrypoint MUSS separat sichtbar werden (z. B. über einen anderen Exit-Code, eine andere Workflow-Step-Grenze oder einen klar markierten Log-Marker), damit eine rote Pipeline sofort sagt, welche Fehlerklasse zu triagieren ist.

- **SOLLTE [SHOULD]**
  - Das Dockerfile SOLLTE unter `tests/` neben Fixtures und Entrypoint-Skript liegen, damit die gesamte Testfläche ein Ordner ist.
  - Der Base-Image-Pin SOLLTE ein Digest sein, kein floatendes Tag, damit ein Upstream-Image-Rebuild nicht stillschweigend das Verhalten zwischen zwei Läufen desselben Commits ändert.
  - Die Pipeline SOLLTE die TAP-Ausgabe von Bats (oder das äquivalente Bats-native Pretty-Format) ins CI-Log schreiben und den TAP-Stream als Workflow-Artefakt hochladen, damit ein Fehler allein aus dem CI heraus debuggbar ist — jeder `@test` und die jeweils inspizierten Artefakte (Tool-Liste, Dotfile-Liste, Venv-Inhaltsstichprobe) tauchen namentlich im Log auf, ohne dass lokal nachgestellt werden muss.
  - Jede `MUSS`-Assertion aus §„Provisionierungs-Nachbedingungen" SOLLTE unabhängig geübt werden, damit ein einzelner Fehlschlag den Rest nicht maskiert.
  - Der Container SOLLTE auf `linux/amd64` laufen. Weitere Architekturen KÖNNEN [MAY] später ergänzt werden, sind aber von dieser Spec nicht gefordert.
  - Der wöchentliche Cron-Lauf SOLLTE sein Ergebnis über denselben Benachrichtigungspfad melden wie andere scheduled Jobs in diesem Repo (keine Sonderfall-Alarmierung).

- **KANN [MAY]**
  - Die Pipeline KANN Container-Image-Layer im GitHub-Actions-Cache zwischenspeichern, sofern der Cache-Key den Dockerfile-Hash mit einschließt, damit eine Dockerfile-Änderung einen Rebuild erzwingt.
  - Die Pipeline KANN einen Smoke-Schritt enthalten, der nach dem Apply ein repräsentatives `task` aus `~/taskfile.yaml` ausführt, um zu verifizieren, dass das getemplatete Taskfile seine Includes gegen `~/.local/share/taskfile-collection/` auflöst.
  - Folge-PRs KÖNNEN die Spec um eine Distro-Matrix erweitern (z. B. Ubuntu LTS + Fedora) — außerhalb des Scopes hier, aber die Implementierung SOLLTE eine Matrix-Erweiterung nicht schwerer machen als ein Tausch des Base-Images.

## Provisionierungs-Nachbedingungen

Der folgende On-Disk-Zustand im Container ist das, was ein grüner Lauf assertet. Der Implementierungs-PR übersetzt das in konkrete Checks; die Spec fixiert den Vertrag.

- Für jedes in `chezmoi_config/dot_tool-versions` gelistete Tool MUSS `asdf which <tool>` einen existierenden, ausführbaren Pfad auflösen. Die Tool-Liste der Assertions wird aus der Datei gelesen, nicht im Test hartkodiert — Drift in `dot_tool-versions` darf keine Parallelpflege der Assertions erfordern.
- `~/.gitconfig` MUSS existieren und MUSS die Dummy-Werte `git_email` / `git_name` aus der Test-`chezmoi.toml`-Fixture enthalten (damit nachgewiesen ist, dass die Template-Substitution wirklich lief).
- `~/.tool-versions` MUSS existieren und MUSS byteidentisch zu `chezmoi_config/dot_tool-versions` sein.
- `~/taskfile.yaml` MUSS existieren und MUSS `~/.local/share/taskfile-collection/` irgendwo in seinem Include-Graphen referenzieren.
- `~/.venvs/development/` und `~/.venvs/docs/` MÜSSEN als gültige Python-Virtualenvs existieren. Jedes MUSS mindestens ein Stichproben-Paket aus dem zugehörigen `requirements-*.txt` enthalten: `pre-commit` für development, `mkdocs-material` für docs.
- Die drei in `.chezmoiexternal.toml` deklarierten zsh-Plugin-Verzeichnisse MÜSSEN als nicht-leere Git-Checkouts unter `~/.oh-my-zsh/custom/plugins/` existieren.
- `~/.local/share/taskfile-collection/` MUSS als nicht-leerer Git-Checkout existieren.
- Jedes `run_onchange_*`-Skript in `chezmoi_config/` MUSS beim ersten Apply einen beobachtbaren Seiteneffekt hinterlassen haben (asdf-Plugins ergänzt, `asdf install` ausgeführt, Venvs angelegt). Das zweite Apply DARF sie NICHT erneut ausführen; der Test prüft das über die `chezmoi apply --verbose`-Ausgabe oder ein äquivalentes chezmoi-natives Signal.

## Verhältnis zu bestehenden Repo-Konventionen

- `CLAUDE.md` nennt zwei strukturelle Tatsachen, die diese Spec übernimmt, ohne sie zu wiederholen: die `.chezmoiroot = chezmoi_config`-Indirektion und die bewusste Duplizierung von `requirements-development.txt` / `requirements-mkdocs.txt` zwischen `docs/` (vom Docs-Delivery-Workflow genutzt) und `chezmoi_config/` (zur Apply-Zeit genutzt). Der Test MUSS die `chezmoi_config/`-Kopien konsumieren, da das die Dateien sind, die `chezmoi apply` tatsächlich installiert.
- Alle `.github/workflows/`-Dateien in diesem Repo sind dünne Wrapper über `nolte/gh-plumbing`-Reusable-Workflows, an unveränderliche Release-Tags gepinnt und gemeinsam von Renovate gebumpt. Der neue Provisionierungs-Test-Workflow SOLLTE diesem Muster folgen *nur falls* es upstream einen passenden Reusable Workflow gibt; andernfalls KANN er ein in sich geschlossener Workflow sein, mit der expliziten Anerkennung, dass er damit der erste Non-Reusable-Workflow in diesem Repo ist.

## Akzeptanzkriterien

- [ ] `tests/` enthält ein `Dockerfile`, eine Test-`chezmoi.toml`-Fixture und ein Entrypoint-Skript. `tests/.gitkeep` ist entfernt.
- [ ] Ein neuer Workflow unter `.github/workflows/` startet den Container auf push/PR auf `develop`, push auf `main` und auf dem Cron-Schedule `16 0 * * 1`.
- [ ] Die Root-`Taskfile.yml` stellt `task test:container` bereit, das dasselbe Image und denselben Entrypoint baut und startet wie der Workflow.
- [ ] Ein sauberer lokaler Aufruf von `task test:container` endet auf dem aktuellen `develop`-Tip mit Exit-Code 0.
- [ ] Während eines grünen Laufs ist `asdf which <tool>` für jedes in `chezmoi_config/dot_tool-versions` gelistete Tool erfolgreich.
- [ ] Während eines grünen Laufs existieren `~/.gitconfig`, `~/.tool-versions` und `~/taskfile.yaml`; `~/.gitconfig` enthält die Dummy-Fixture-Werte; `~/.tool-versions` ist byteidentisch zu `chezmoi_config/dot_tool-versions`.
- [ ] Während eines grünen Laufs enthält `~/.venvs/development/` `pre-commit` und `~/.venvs/docs/` `mkdocs-material`.
- [ ] Während eines grünen Laufs existieren die drei zsh-Plugin-Verzeichnisse unter `~/.oh-my-zsh/custom/plugins/` und `~/.local/share/taskfile-collection/` als nicht-leere Git-Checkouts.
- [ ] Die Assertion-Suite liegt unter `tests/*.bats`, jeder `MUSS`-Eintrag aus §„Provisionierungs-Nachbedingungen" mappt auf genau einen `@test`-Block, und ein einzelner fehlgeschlagener `@test` überspringt die übrigen Assertions nicht.
- [ ] Ein zweites direkt nachfolgendes `chezmoi apply` endet mit Exit-Code 0 und löst keine erneute Ausführung der `run_onchange_*`-Skripte aus.
- [ ] Der Container-Lauf bindet kein Host-`$HOME` ein, verlangt kein `--privileged` und mountet keinen Docker-Socket.
- [ ] `build-static-tests.yaml` läuft weiterhin unverändert auf denselben Triggern; nichts in der neuen Pipeline ersetzt oder kurzschließt deren Jobs.
- [ ] Eine bewusst kaputtmachende Änderung an `chezmoi_config/dot_tool-versions` (z. B. eine nicht existierende Tool-Version) lässt die neue Pipeline fehlschlagen; das Zurücknehmen der Änderung macht sie wieder grün.
- [ ] Der Base-Image-Pin und der Bats-Versions-Pin tauchen beide im Renovate-Dashboard auf, und Update-PRs für beide lassen sich von Renovate ohne manuelle Konfig-Eingriffe öffnen.

## Offene Fragen

- Soll das Image gebaut und nach GHCR gepusht werden, damit der Cron-Job und der Per-PR-Job es teilen können, oder in jedem Job neu gebaut? Trade-off ist Registry-Pflege gegen Build-Zeit.
- Ist beim zweiten Apply das Parsen von `chezmoi apply --verbose` zuverlässig genug, um die erneute Ausführung von `run_onchange_*`-Skripten zu erkennen, oder brauchen wir ein chezmoi-natives Signal (z. B. Vergleich von State-Hashes)? Das beeinflusst, ob der Test von einem CLI-Ausgabeformat abhängt, das sich zwischen chezmoi-Releases ändern kann.
- Reicht eine Single-Distro-Baseline (Ubuntu LTS) für den Anfang, oder sollte die erste Iteration bereits eine zweite Distro enthalten, um Ubuntu-spezifische Drift zu verhindern? Aktuelle Entscheidung: erst Single-Distro, Matrix später — nach den ersten drei Monaten grüner Läufe neu bewerten.
