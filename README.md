# Solution2
C#でウェブアプリを作成し、Dockerで実行してみる。


# C#でウェブアプリを作成して、Dockerで実行するまで手順。


# 環境
	[Register]アカウント登録    https://hub.docker.com

	macOS Ventura
	zsh                     既定のShell
	.NET 7.0                https://learn.microsoft.com/ja-jp/dotnet/core/install/macos
	Visual Studio Code      https://code.visualstudio.com/
	GitHub CLI              https://cli.github.com/
	Docker DeskTop          https://desktop.docker.com/mac/main/amd64/Docker.dmg    （メモ Mac with Intel chip）


# 開発中に HTTPS を使用できるようにするため、開発の自己証明書を信頼する。

	<ターミナル>

	# pwd
	# /Users/xxxxxx

    参考ドキュメント
    https://learn.microsoft.com/ja-JP/dotnet/core/tools/dotnet-dev-certs

	dotnet dev-certs https --trust


# ”Solution2”という名前の公開リポジトリをGitHub上に作成する。その複製（クローン）をローカルに作成する。

	1. ”Solution2”という名前のリポジトリを新規作成する。

		<ターミナル>

		# pwd
		# /Users/xxxxxx/github
		#
		# ls -a
		# .    ..    Solution1

		gh repo create

		アシスタントに従って設定をする。
			? What would you like to do? [Create a new repository on GitHub from scratch]
			? Repository name [Solution2]
			? Description [何でもいいから説明を書く]
			? Visibility [Public]
			? Would you like to add a README file? [Yes]
			? Would you like to add a .gitignore? [Yes]
			? Choose a .gitignore template [C++]（作り直すのでどれを選んでも良い）
			? Would you like to add a license? [Yes]
			? Choose a license [MIT License]
			? This will create "Solution2" as a public repository on GitHub. Continue? [Yes]
			? Clone the new repository locally? [Yes]

		# ls -a
		# .    ..    Solution1    Solution2


# ソース管理から除外するファイルのリストを作成する。

	1. C＃ソースを管理するにあたり、一般的に除外すべきファイルの一覧を、生成してもらう。

		<ブラウザ>

		https://www.toptal.com/developers/gitignore
		[macOS] [VisualStudioCode] [Csharp]　を入力して、[作成する]ボタンを押す。
		表示された内容を全て選択して、コピーする。

	2. .gitignoreファイルの内容を、全て置き換える。

		<ターミナル>

		cd Solution2 

		# pwd
		# /Users/xxxxxx/github/Solution2
		#
		# ls -a
		# .    ..    .git    .gitignore    LICENSE    README.md

		pbpaste > .gitignore


# C#のWebアプリを作成する。

	<ターミナル>

	# pwd
	# /Users/xxxxxx/github/Solution2

	dotnet new sln

	dotnet new mvc --name WebApplication2 --output ./WebApplication2/

	dotnet sln add WebApplication2/WebApplication2.csproj

	dotnet run --project WebApplication2/WebApplication2.csproj --launch-profile https

	-------------------------------------------------------------------------
	# WebApplication2/Properties/launchSettings.json に記述されている起動プロファイルのうち、"https"を指定して開始している。
	参考ドキュメント
	https://learn.microsoft.com/ja-jp/aspnet/core/fundamentals/environments?view=aspnetcore-7.0

	Now listening on: https://localhost:7087
	Now listening on: http://localhost:5185

	URLをブラウザに貼り付けて、”Home”が表示されることを確認する。
	-------------------------------------------------------------------------

	dotnet publish --configuration Release


# C#のWebアプリをDockerで実行する。

	1. ASP.NET Coreのコンテナイメージを基に、作成したウェブアプリを追加する。

	参考ドキュメント
	https://learn.microsoft.com/ja-jp/dotnet/architecture/microservices/docker-application-development-process/docker-app-development-workflow

	参考ドキュメント
	https://docs.docker.jp/engine/reference/builder.html

	<ターミナル>

	# pwd
	# /Users/xxxxxx/github/Solution2

	touch Dockerfile

	Dockerfileに記述する内容について
	・マイクロソフトがオフィシャルで用意している、aspnetバージョン7.0コンテナイメージを基に生成してください。
	・コンテナ内に、appディレクトリを作成して、そのディレクトに移動してください。
	・コンテナ側の80(HTTP)ポートを開けてください。
	・母体側の（/Users/xxxxxx/github/Solution2/WebApplication2/bin/Release/net7.0/publish）ディレクトリの内容を、
	　コンテナ内の（先ほど作成した、app）ディレクトリにコピーしてください。
	・コンテナを起動した時は、dotnetコマンド 引数として WebApplication2.dll を実行してください。

	/Users/xxxxxx/github/Solution2/Dockerfile をエディタで編集する。
	-------------------------------------------------------------------------
	FROM mcr.microsoft.com/dotnet/aspnet:7.0
	WORKDIR /app
	EXPOSE 80
	COPY WebApplication2/bin/Release/net7.0/publish .
	ENTRYPOINT [ "dotnet", "WebApplication2.dll" ]
	-------------------------------------------------------------------------

	2. Dockerfile の内容に従って、新しいコンテナイメージを作成する。

	# pwd
	# /Users/xxxxxx/github/Solution2

	内容について
	・カレントディレクトリにあるDockerfileに従って、webapplication2という名前のコンテナイメージを作成してください。

	docker build . --tag webapplication2

	3. 作成したコンテナを実行する。

	内容について
	・識別名を webapp002 としてください。
	・母体側の8000ポートと、コンテナ内の80ポートを繋いでください。
	・実行するコンテナは、webapplication2 です。

	docker run --name webapp002 -d -p 8000:80 webapplication2

	-------------------------------------------------------------------------
	http://localhost:8000
	URLをブラウザに貼り付けて、”Home”が表示されることを確認する。
	-------------------------------------------------------------------------

	4. コンテナを停止する。

	docker stop webapp002

# 作成したソースコードをGitHubに登録する。

	# pwd
	# /Users/xxxxxx/github/Solution2

	# （ローカル）ワークツリーから、インデックスに登録する。
	git add .

	# （ローカル）インデックスから、ローカルのリポジトリに登録する。
	git commit

	# （ローカル）リポジトリから、（Git Hub）Solution2 公開リポジトリに登録（変更を反映）する。
	git push



