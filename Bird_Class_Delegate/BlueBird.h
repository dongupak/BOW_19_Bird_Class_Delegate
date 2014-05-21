//
//  BlueBird.h
//  Birds
//
//  Created by Youngrok Lee on 10. 9. 5..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Bird.h" //Bird 클래스를 상속받는다.

// Bird형 BlueBird를 만듭니다.
// Bird는 CCSprite이므로 BlueBird 또한 CCSprite 입니다.
// Bird가 가진 isDead, startPoint, flyAnimate, tailAnimate 변수를 그대로 가지므로 쓸 수 있습니다.
// Bird가 가진 (void)action, (void)setIsDead:(BOOL)val 메소드를 가집니다.
@interface BlueBird : Bird {
	
}

@end
