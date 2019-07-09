# JuMP_SCIP

# まずはSCIPをインストールし，環境変数にパスを通しておく必要がある。
# ┌ Error: Error building `SCIP`:
# │ ERROR: LoadError: Unable to locate SCIP installation.
# │ Tried:
# │       scip.dll
# │ Note that this must be downloaded separately from scip.zib.de.
# │ Please set the environment variable SCIPOPTDIR to SCIP's installation path.
#
# そしてそのSCIPのインストールにはビルド自動化のためのフリーソフトウェアCMakeが必要
# https://cmake.org/download/
# CMakeをビルドするためにはMacではC++コンパイラが使えるが，Winではbinaryバージョンを拾ってくる必要がありそう。
# さらにhttps://www.msys2.org/も必要？？？
