# これはなに？

WordPressのプラグインやテーマを開発する環境を構築するものです。
コンテナ内にSSL証明書の認証局を構築するので、その認証局の証明書をホストに登録することでFirefox以外のブラウザの警告を抑止することができます。

# セットアップ

`docker-compose up` してコンテナが立ち上がったら `docker cp ${PROJECT_NAME}-ap:/etc/apache2/ssl/root-ca/root-ca.crt .` で証明書を取得します。
取得した証明書をキーチェーンに登録して信頼するよう設定すればブラウザは警告しなくなります。

# 使い方

`docker-compose exec --user www-data ap ../bin/wp-launch.sh` を実行すると `.env` に指定された環境変数をつかって `localhost:8443` にWordPressをインストールします。
`composer` と `wp`（wp-cli）は `/usr/local/bin` に配置しています。
