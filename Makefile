# Makefile for Docker Nginx PHP Composer MySQL

include .env

# MySQL
MYSQL_DUMPS_DIR=data/db/dumps

help:
	@echo ""
	@echo "usage: make COMMAND"
	@echo ""
	@echo "Commands:"
	@echo "  apidoc              Gera documentação para API"
	@echo "  code-sniff          Checa a API com PHP Code Sniffer (PSR2)"
	@echo "  clean               Limpa e reseta diretórios do projeto"
	@echo "  composer-up         Update dependências do PHP com composer"
	@echo "  docker-start        Cria e inicia containers"
	@echo "  docker-stop         Para e limpa todos os serviços"
	@echo "  gen-certs           Gera certificados SSL"
	@echo "  logs                Imprime os logs do projeto"
	@echo "  mysql-dump          Cria backup das databases"
	@echo "  mysql-restore       Reustaura backup das databases"
	@echo "  phpmd               Analisa a API com PHP Mess Detector"
	@echo "  test                Testa aplicação"
	@echo "  clone               Clona o submódulo do TunX"

init:
	@$(shell cp -n $(shell pwd)/web/app/composer.json.dist $(shell pwd)/web/app/composer.json 2> /dev/null)

apidoc:
	@docker run --rm -v $(shell pwd):/data phpdoc/phpdoc -i=vendor/ -d /data/web/app/src -t /data/web/app/doc
	@make resetOwner

clean:
	@rm -Rf data/db/mysql/*
	@rm -Rf $(MYSQL_DUMPS_DIR)/*
	@rm -Rf web/
	@rm -Rf etc/ssl/*

code-sniff:
	@echo "Checando o standard code..."
	@docker-compose exec -T php ./app/vendor/bin/phpcs -v --standard=PSR2 app/src

composer-up:
	@docker run --rm -v $(shell pwd)/web/app:/app composer update

docker-start: init
	docker-compose up -d

docker-stop:
	@docker-compose down -v
	@make clean

gen-certs:
	@docker run --rm -v $(shell pwd)/etc/ssl:/certificates -e "SERVER=$(NGINX_HOST)" jacoelho/generate-certificate

logs:
	@docker-compose logs -f

mysql-dump:
	@mkdir -p $(MYSQL_DUMPS_DIR)
	@docker exec $(shell docker-compose ps -q mysqldb) mysqldump --all-databases -u"$(MYSQL_ROOT_USER)" -p"$(MYSQL_ROOT_PASSWORD)" > $(MYSQL_DUMPS_DIR)/db.sql 2>/dev/null
	@make resetOwner

mysql-restore:
	@docker exec -i $(shell docker-compose ps -q mysqldb) mysql -u"$(MYSQL_ROOT_USER)" -p"$(MYSQL_ROOT_PASSWORD)" < $(MYSQL_DUMPS_DIR)/db.sql 2>/dev/null

phpmd:
	@docker-compose exec -T php \
	./app/vendor/bin/phpmd \
	./app/src text cleancode,codesize,controversial,design,naming,unusedcode

test: code-sniff
	@docker-compose exec -T php ./app/vendor/bin/phpunit --colors=always --configuration ./app/
	@make resetOwner

resetOwner:
	@$(shell chown -Rf $(SUDO_USER):$(shell id -g -n $(SUDO_USER)) $(MYSQL_DUMPS_DIR) "$(shell pwd)/etc/ssl" "$(shell pwd)/web" 2> /dev/null)

clone:
	@chmod 600 $(shell pwd)/etc/php/github_rsa
	@ssh-keyscan github.com >> $(shell pwd)/etc/php/github_rsa
	@eval "$(ssh-agent -s)"
	@git clone git@github.com:git-powerx/tunx.git $(shell pwd)/web

.PHONY: clean test code-sniff init