//
//  BirdsSprite.m
//  GameDemo
//
//  Created by Youngrok Lee on 10. 9. 5..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Bird.h"

@implementation Bird
//헤더파일에서 지정한 프로퍼티 지시문을 통해 컴파일러가 만든 settet/getter를 자동구현합니다.
@synthesize flyAnimate;
@synthesize sitAnimate;
@synthesize tailAnimate;
@synthesize sitPoint;
@synthesize startPoint;
@synthesize isDead;
@synthesize delegate;

- (void)dealloc {
	if (flyAnimate != nil)	[self setFlyAnimate:nil];
	if (sitAnimate != nil)	[self setSitAnimate:nil];
	if (tailAnimate != nil)	[self setTailAnimate:nil];
    [super dealloc];
}

- (id)init {
	self=[super init];
	if (self==nil) return nil;
    return self;
}

// action 메소드는 flyAnimate를 지정위치 self,position, sit Point 까지 움직이며 보여준 후,
// 움직임이 끝나면 onLine 메소드를 실행합니다.
- (void)action{
	id actionFly    = [CCRepeatForever actionWithAction:flyAnimate];
    id actionMove   = [CCMoveTo actionWithDuration:ccpDistance(self.position, sitPoint)/150 position:sitPoint];
    id moveComplete = [CCCallFunc actionWithTarget:self selector:@selector(onLine)];
    [self runAction:actionFly];
    [self runAction:[CCSequence actions:actionMove, moveComplete, nil]];
}

// sitAnimate 를 끊임없이 반복적으로 보여줍니다.
- (void)onLine {
	id actionSit=[CCRepeatForever actionWithAction:sitAnimate];
    [self stopAllActions];
    [self runAction:actionSit];
}

// 받은값 val를 isDead에 대응시킨 후,
// isDead 값이 1(YES)이면 모든 action을 정지 시킨후, tailAnimate 액션과 deadComplete 액션을 순차적으로 실행합니다.
- (void)setIsDead:(BOOL)val {
    isDead = val;
    if(isDead) {
        [self stopAllActions];
        id deadComplete = [CCCallFunc actionWithTarget:self selector:@selector(deadComplete)];
        [self runAction:[CCSequence actions:tailAnimate, deadComplete, nil]];
    }
}

// delegate를 연결시켜 GameLayer의 deadComplete를 연결할 수 있도록 합니다.
// deadComplete:self 함으로서 이 객체의 처리를 GameLayer에서 할 수 있도록 합니다.
- (void)deadComplete {
    [self.delegate deadComplete:self];
}

@end
