//
//  GameViewController.m
//  Ping-pong
//
//  Created by Anastasia Romanova on 21/04/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

#import "GameViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define HALF_SCREEN_WIDTH SCREEN_WIDTH/2
#define HALF_SCREEN_HEIGHT SCREEN_HEIGHT/2
#define MAX_SCORE 6

@interface GameViewController ()

@property (strong, nonatomic) UIImageView *paddleTop;
@property (strong, nonatomic) UIImageView *paddleBottom;
@property (strong, nonatomic) UIView *gridView;
@property (strong, nonatomic) UIView *ball;
@property (strong, nonatomic) UITouch *topTouch;
@property (strong, nonatomic) UITouch *bottomTouch;
@property (strong, nonatomic) NSTimer * timer;
@property (nonatomic) float dx;
@property (nonatomic) float dy;
@property (nonatomic) float speed;
@property (nonatomic) int scoreTopPlayer;
@property (nonatomic) int scoreBottomPlayer;
@property (strong, nonatomic) UILabel *scoreTopLabel;
@property (strong, nonatomic) UILabel *scoreBottomLabel;

@end

@implementation GameViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self config];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self becomeFirstResponder];
  [self newGame];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [self resignFirstResponder];
}

#pragma mark - Подготовка UI

- (void)config {
  _scoreTopPlayer = 0;
  _scoreBottomPlayer = 0;
  self.view.backgroundColor = [UIColor colorWithRed:100.0/255.0 green:135.0/255.0 blue:191.0/255.0 alpha:1.0];
  
  _gridView = [[UIView alloc] initWithFrame:CGRectMake(0, HALF_SCREEN_HEIGHT - 2, SCREEN_WIDTH, 4)];
  _gridView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
  [self.view addSubview:_gridView];
  
  _paddleTop = [[UIImageView alloc] initWithFrame:CGRectMake(30, 40, 90, 60)];
  _paddleTop.image = [UIImage imageNamed:@"paddleTop"];
  _paddleTop.contentMode = UIViewContentModeScaleAspectFit;
  [self.view addSubview:_paddleTop];
  
  _paddleBottom = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 120, SCREEN_HEIGHT - 90, 90, 60)];
  _paddleBottom.image = [UIImage imageNamed:@"paddleBottom"];
  _paddleBottom.contentMode = UIViewContentModeScaleAspectFit;
  [self.view addSubview:_paddleBottom];
  
  _ball = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x - 10, self.view.center.y - 10, 20, 20)];
  _ball.backgroundColor = [UIColor whiteColor];
  _ball.layer.cornerRadius = 10;
  _ball.hidden = YES;
  [self.view addSubview:_ball];
  
  _scoreTopLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 70, HALF_SCREEN_HEIGHT - 70, 50, 50)];
  _scoreTopLabel.textColor = [UIColor whiteColor];
  _scoreTopLabel.text = [NSString stringWithFormat: @"%d", _scoreTopPlayer];
  _scoreTopLabel.font = [UIFont systemFontOfSize:40.0 weight:UIFontWeightLight];
  _scoreTopLabel.textAlignment = NSTextAlignmentCenter;
  [self.view addSubview:_scoreTopLabel];
  
  _scoreBottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 70, HALF_SCREEN_HEIGHT + 20, 50, 50)];
  _scoreBottomLabel.textColor = [UIColor whiteColor];
  _scoreBottomLabel.text = [NSString stringWithFormat: @"%d", _scoreBottomPlayer];
  _scoreBottomLabel.font = [UIFont systemFontOfSize:40.0 weight:UIFontWeightLight];
  _scoreBottomLabel.textAlignment = NSTextAlignmentCenter;
  [self.view addSubview:_scoreBottomLabel];
}

#pragma mark - Обработка касаний

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  for (UITouch *touch in touches) {
    CGPoint point = [touch locationInView:self.view];
    if (self.bottomTouch == nil && point.y > HALF_SCREEN_HEIGHT) {
      self.bottomTouch = touch;
      self.paddleBottom.center = CGPointMake(point.x, point.y);
    }
//    else if (self.topTouch == nil && point.y < HALF_SCREEN_HEIGHT) {
//      self.topTouch = touch;
//      self.paddleTop.center = CGPointMake(point.x, point.y);
//    }
  }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  for (UITouch *touch in touches) {
    CGPoint point = [touch locationInView:self.view];
//    if (touch == self.topTouch) {
//      if (point.y > HALF_SCREEN_HEIGHT) {
//        self.paddleTop.center = CGPointMake(point.x, HALF_SCREEN_HEIGHT);
//        return;
//      }
//      self.paddleTop.center = point;
//    }
    if (touch == self.bottomTouch) {
      if (point.y < HALF_SCREEN_HEIGHT) {
        self.paddleBottom.center = CGPointMake(point.x, HALF_SCREEN_HEIGHT);
        return;
      }
      self.paddleBottom.center = point;
    }
  }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  for (UITouch *touch in touches) {
//    if (touch == self.topTouch) {
//      self.topTouch = nil;
//    }
    if (touch == self.bottomTouch) {
      self.bottomTouch = nil;
    }
  }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self touchesEnded:touches withEvent:event];
}

#pragma mark - Логика Игры

- (void)reset {
  if ((arc4random() % 2) == 0) {
    self.dx = -1;
  } else {
    self.dx = 1;
  }
  
  if (self.dy != 0) {
    self.dy = -self.dy;
  } else if ((arc4random() % 2) == 0) {
    self.dy = -1;
  } else  {
    self.dy = 1;
  }
  
  self.ball.center = CGPointMake(HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT);

  self.speed = 2;
}

- (void)newGame {
  [self reset];
  
  self.scoreTopPlayer = 0;
  self.scoreBottomPlayer = 0;
  self.paddleTop.frame = CGRectMake(30, 40, 90, 60);
  
  [self displayMessage:@"Готовы к игре?"];
}

- (int)isGameOver {
  if (self.scoreTopPlayer == MAX_SCORE) return 1;
  else if (self.scoreBottomPlayer == MAX_SCORE) return 2;
  return 0;
}

- (void)displayMessage:(NSString *)message {
  [self stopTimer];
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ping Pong" message:message preferredStyle:(UIAlertControllerStyleAlert)];
  UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    if ([self isGameOver]) {
      [self newGame];
      return;
    }
    [self reset];
    [self startTimer];
  }];
  [alertController addAction:action];
  [self presentViewController:alertController animated:YES completion:nil];
}

- (void)startTimer {
  self.ball.center = CGPointMake(HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT);
  if (!self.timer) {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(animate) userInfo:nil repeats:YES];
  }
  self.ball.hidden = NO;
}

- (void)stopTimer {
  if (self.timer) {
    [self.timer invalidate];
    self.timer = nil;
  }
  self.ball.hidden = YES;
}

- (void)animate {
  CGRect paddleTopFrameForCollision = CGRectMake(self.paddleTop.frame.origin.x, self.paddleTop.frame.origin.y + 5, 50, 50);
  CGRect paddleBottomFrameForCollision = CGRectMake(self.paddleBottom.frame.origin.x + 40, self.paddleBottom.frame.origin.y + 5, 50, 50);
  
  self.ball.center = CGPointMake(self.ball.center.x + self.dx*self.speed, self.ball.center.y + self.dy*self.speed);
  
  //Artificial intelligence
  int paddleMidX = self.paddleTop.frame.origin.x + paddleTopFrameForCollision.size.width/2;
  int diffX = paddleMidX - self.ball.center.x;
  CGFloat originX = self.paddleTop.frame.origin.x;
  CGFloat originY = self.paddleTop.frame.origin.y;
  
  if (self.ball.center.y >= HALF_SCREEN_HEIGHT) {
    originY += 0.1 * self.speed;
    if (originY > HALF_SCREEN_HEIGHT - 60) {
      originY = HALF_SCREEN_HEIGHT - 60;
    };
  } else {
    originY += -0.5 * self.speed;
    if (originY < 40) {
      originY = 40;
    };
  };
  
  
  if (diffX > 0) {
    originX += - 0.7 * self.speed;
  } else if (diffX < 0) {
    originX += 0.7 * self.speed;
  };
  
  self.paddleTop.frame = CGRectMake(originX, originY, self.paddleTop.frame.size.width, self.paddleTop.frame.size.height);
  
  [self checkCollision:CGRectMake(0, 0, -20, SCREEN_HEIGHT) X:-self.dx Y:0];
  [self checkCollision:CGRectMake(SCREEN_WIDTH, 0, 20, SCREEN_HEIGHT) X:-self.dx Y:0];
  if ([self checkCollision:paddleTopFrameForCollision X:(self.ball.center.x - self.paddleTop.center.x) / 32.0 Y:1]) {
    [self increaseSpeed];
  }
  if ([self checkCollision:paddleBottomFrameForCollision X:(self.ball.center.x - self.paddleBottom.center.x) / 32.0 Y:-1]) {
    [self increaseSpeed];
  }
  [self goal];
}

- (BOOL)checkCollision: (CGRect)rect X:(float)x Y:(float)y {
  if (CGRectIntersectsRect(self.ball.frame, rect)) {
    if (x != 0) self.dx = x;
    if (y != 0) self.dy = y;
    return YES;
  }
  return NO;
}

- (void)increaseSpeed {
  self.speed += 0.5;
  if (self.speed > 10) self.speed = 10;
}

- (BOOL)goal
{
  if (self.ball.center.y < 0 || self.ball.center.y >= SCREEN_HEIGHT) {

    if (self.ball.center.y < 0) ++self.scoreBottomPlayer; else ++self.scoreTopPlayer;
    self.scoreTopLabel.text = [NSString stringWithFormat:@"%d", self.scoreTopPlayer];
    self.scoreBottomLabel.text = [NSString stringWithFormat:@"%d", self.scoreBottomPlayer];
    
    int gameOver = [self isGameOver];
    if (gameOver) {
      if (gameOver == 1) {
        [self displayMessage:[NSString stringWithFormat:@"Вы проиграли!"]];
      }
      else if (gameOver == 2) {
        [self displayMessage:[NSString stringWithFormat:@"Вы выиграли!"]];
      };
    } else {
      [self reset];
    }
    
    return YES;
  }
  return NO;
}

@end
