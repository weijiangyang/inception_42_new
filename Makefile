# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: weiyang <weiyang@student.42.fr>                  +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/06/07 18:14:30 by weiyang           #+#    #+#              #
#    Updated: 2026/06/09 10:38:07 by weiyang            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = inception

COMPOSE_FILE = srcs/docker-compose.yml
DOCKER_COMPOSE = docker compose -f $(COMPOSE_FILE)

# Persistent Volume Path Matrices
DB_DIR = /home/weiyang/data/mariadb
WP_DIR = /home/weiyang/data/wordpress
REDIS_DIR = /home/weiyang/data/redis
RESUME_DIR = /home/weiyang/data/resume

# Default rule: Start mandatory core containers only
all: up

up:
	@echo "[Makefile] Creating core mandatory storage directories..."
	@sudo mkdir -p $(DB_DIR)
	@sudo mkdir -p $(WP_DIR)
	@sudo mkdir -p $(RESUME_DIR)
	
	@echo "[Makefile] Clearing old object-cache drop-in safely..."
	@if [ -f "$(WP_DIR)/wp-content/object-cache.php" ]; then sudo rm -f "$(WP_DIR)/wp-content/object-cache.php"; fi
	
	@echo "[Makefile] Forcing no-cache build for mariadb image..."
	@$(DOCKER_COMPOSE) build --no-cache mariadb
	
	@echo "[Makefile] Bootstrapping core stack (Nginx, WordPress, MariaDB)..."
	@$(DOCKER_COMPOSE) up -d --build wordpress nginx

# Stop services gracefully across all profiles
down:
	@echo "[Makefile] Stopping all services gracefully..."
	@$(DOCKER_COMPOSE) --profile bonus stop

# Tear down containers and networks
clean:
	@echo "[Makefile] Removing containers and networks..."
	@$(DOCKER_COMPOSE) --profile bonus down

# Bonus rule: Start the full stack including all bonus services
bonus: clean
	@echo "[Makefile] Creating all storage directories including bonus paths..."
	@sudo mkdir -p $(DB_DIR)
	@sudo mkdir -p $(WP_DIR)
	@sudo mkdir -p $(REDIS_DIR)
	@sudo mkdir -p $(RESUME_DIR)
	@sudo cp -r assets/resume/ $(RESUME_DIR)
	@echo "[Makefile] Bootstrapping full stack with bonus features..."
	@echo "[Makefile] Forcing no-cache build for mariadb image..."
	@$(DOCKER_COMPOSE) build --no-cache mariadb
	@$(DOCKER_COMPOSE) --profile bonus up -d --build wordpress nginx redis ftp adminer monitoring

# Wipe all containers, cached data, and physical host volumes completely
fclean: clean
	@echo "[Makefile] Eradicating physical persistent data volumes..."
	@sudo rm -rf $(DB_DIR)
	@sudo rm -rf $(WP_DIR)
	@sudo rm -rf $(REDIS_DIR)
	@sudo rm -rf $(RESUME_DIR)
	
	@echo "[Makefile] Eradicating Docker custom networks explicitly..."
	@docker network rm srcs_inception_network 2>/dev/null || true
	@docker network prune -f

	@echo "[Makefile] Eradicating Docker named volumes metadata explicitly..."
	@docker volume rm srcs_mariadb_data srcs_wordpress_data srcs_resume_data srcs_redis_data monitoring_data 2>/dev/null || true
	@echo "[Makefile] Purging unused Docker build cache and layers..."
	@docker system prune -a -f --volumes

# Full rebuild rules
re: fclean all
re_bonus: fclean bonus

.PHONY: all up bonus down clean fclean re re_bonus