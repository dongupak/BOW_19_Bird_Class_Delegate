//
//  Bird.h
//  GameDemo
//
//  Created by Youngrok Lee on 10. 9. 5..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "AppDelegate.h"
#import "cocos2d.h"

//프로토콜을 선언합니다.
@protocol BirdDelegate;

// CCSprite을 클래스화 시킵니다.
// CCSprite형 Bird는 isDead, startPoint, flyAnimate, tailAnimate 변수를 가집니다.
@interface Bird : CCSprite {
    BOOL isDead;
    CGPoint startPoint;
	CGPoint sitPoint;
	CCAnimate *flyAnimate;
	CCAnimate *sitAnimate;
	CCAnimate *tailAnimate;
    id delegate;
}

//set,get 메소드를 컴파일러가 자동으로 생성하도록 합니다.
@property (nonatomic) BOOL isDead;
@property CGPoint sitPoint;
@property CGPoint startPoint;
@property (nonatomic, assign) CCAnimate *flyAnimate;
@property (nonatomic, assign) CCAnimate *sitAnimate;
@property (nonatomic, assign) CCAnimate *tailAnimate;
@property (nonatomic, assign) id delegate;

- (void)action;
- (void)setIsDead:(BOOL)val;
@end

//deadComplete: 라는 메소드로 구성된 프로토콜 BirdDelegate 입니다.
@protocol BirdDelegate
- (void)deadComplete:(Bird *)bird;
@end

