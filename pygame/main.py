import pygame
import os


WIDTH, HEIGHT = 900, 500
WIN = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("First Game!")

WHITE = (255, 255, 255)

FPS = 60
SPACESHIP_WIDHT, SPACESHIP_HEIGHT = 55, 40


YELLOW_SPACE_IMAGE = pygame.image.load(os.path.join('Assets', 'spaceship_yellow.png'))

YELLOW_SPACESHIP = pygame.transform.rotate(pygame.transform.scale(YELLOW_SPACE_IMAGE, (SPACESHIP_WIDHT, SPACESHIP_HEIGHT)), 90)

RED_SPACE_IMAGE = pygame.image.load(os.path.join('Assets', 'spaceship_red.png'))  

RED_SPACESHIP = pygame.transform.scale(RED_SPACE_IMAGE, (SPACESHIP_WIDHT, SPACESHIP_HEIGHT))


def draw_window():
    WIN.fill(WHITE)
    WIN.blit(YELLOW_SPACESHIP, (300, 100))
    pygame.display.update()  



def main():
    clock = pygame.time.Clock()
    run = True
    while run:
        clock.tick(FPS)
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                run = False

        draw_window()
        
    pygame.quit()

if __name__ == "__main__":
    main()