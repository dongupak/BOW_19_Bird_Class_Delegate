//
//  GameLayer.h
//  Action_Move
//
//  Created by 영록 이 on 11. 8. 12..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "BlueBird.h"

@interface GameLayer : CCLayer {
    int bulletCount;
    int score;//점수 저장위한 변수
    
    CCAnimate *sitAnimate;
    CCAnimate *smokeAnimate;
    CCAnimate *tailAnimate;
    CCSprite *gunSmoke;
    CCArray *birdArray;
    CCArray *sitPositions;
    
    CCProgressTimer *ptBullet;
    CCProgressTimer *ptReload;
    CCSprite *ptBulletSprite;
    CCSprite *ptReloadSprite;
    
    CCLabelBMFont *lblScore;//화면에 점수를 나타낼 label
}
+(CCScene *) scene;
-(CGPoint)getStartPosition;
@end
