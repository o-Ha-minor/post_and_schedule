#!/usr/bin/env bash
# Node.jsビルドを先に実行
yarn install
yarn build

# Railsのビルドを実行
bundle install
bundle exec rake assets:precompile
