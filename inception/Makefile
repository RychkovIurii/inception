# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: irychkov <irychkov@student.hive.fi>        +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/07/26 09:53:53 by irychkov          #+#    #+#              #
#    Updated: 2025/08/22 14:56:25 by irychkov         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME=inception

all:
	@if [ ! -d "/home/irychkov/data/db" ]; then \
		mkdir -p /home/irychkov/data/db; \
	fi
	@if [ ! -d "/home/irychkov/data/wp" ]; then \
		mkdir -p /home/irychkov/data/wp; \
	fi
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env up --build

down:
	docker compose -f srcs/docker-compose.yml down

fclean: down
	@if [ -d "/home/irychkov/data/db" ]; then \
		rm -rf /home/irychkov/data/db; \
	fi
	@if [ -d "/home/irychkov/data/wp" ]; then \
		rm -rf /home/irychkov/data/wp; \
	fi
	docker system prune -af --volumes
# rm -rf /home/irychkov/data
# prune removes unused data, -a removes all unused images, not just dangling ones,
# -f forces the removal without confirmation, --volumes removes all unused volumes

re: fclean all

.PHONY: all down fclean re
