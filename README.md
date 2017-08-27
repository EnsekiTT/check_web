# check_web
ウェブサイトをたまに見に行って変化があったら教えてくれるやつ

## Install
```
# Rubyの文字コードをUTF-8にする
path\to\workspace> set RUBYOPT=-EUTF-8

# Bundlerをインストールする
path\to\workspace> gem install bundler

# Bundleでrequireファイルをインストールする（--path .bundleでローカルエリアのみ反映）
path\to\workspace> bundle install --path .bundle
```

## Run
```
bundle exec ruby webcheck.rb
```
