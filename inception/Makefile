# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: irychkov <irychkov@student.hive.fi>        +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/07/26 09:53:53 by irychkov          #+#    #+#              #
#    Updated: 2025/07/26 09:54:12 by irychkov         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME=inception

all:
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env up --build

down:
	docker compose -f srcs/docker-compose.yml down

fclean: down
	docker system prune -af --volumes

re: fclean all

.PHONY: all down fclean re
