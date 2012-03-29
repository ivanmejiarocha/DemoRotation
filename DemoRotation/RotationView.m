/*
 RotationView.m
 
 The MIT License
 
 Copyright (c) México 2012 Iván Mejía
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

#import <QuartzCore/QuartzCore.h>
#import <GLKit/GLKMath.h>
#import "RotationView.h"

@interface RotationView ()
{
   GLKVector3 lastTouchVector_;
   GLKVector3 originVector_;
}

- (GLKVector3) touchPointToVector:(CGPoint) point;

@end

@implementation RotationView

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
   if (self) 
   {
      CALayer * innerLayer = [CALayer layer];
      innerLayer.frame = CGRectMake(0, (self.frame.size.height - self.frame.size.width) / 2.0f, self.frame.size.width, self.frame.size.width);
      innerLayer.contents = (id)[UIImage imageNamed:@"Image.png"].CGImage;
      
      originVector_ = GLKVector3Make(innerLayer.position.x, innerLayer.position.y, 0.0f);
      
      [self.layer addSublayer:innerLayer];
   }
   return self;
}

#pragma math calculations

- (GLKVector3) touchPointToVector:(CGPoint)point
{
   GLKVector3 touchVector = GLKVector3Make(point.x, point.y, 0.0f);
   return GLKVector3Normalize(GLKVector3Subtract(touchVector, originVector_));
}

- (CGFloat) calculateRotationAngle:(CGPoint) point
{
   GLKVector3 currentTouchVector = [self touchPointToVector:point];   
   CGFloat rotationAngle = GLKVector3Length(GLKVector3Subtract(currentTouchVector, lastTouchVector_));
   
   GLKVector3 crossProd = GLKVector3CrossProduct(currentTouchVector, lastTouchVector_);
   CGFloat rotationDirection = crossProd.z > 0 ? -1 : 1;
   
   lastTouchVector_ = currentTouchVector;
   
   return rotationAngle * rotationDirection;
}

#pragma touch events

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   UITouch * touch = [touches anyObject];
   CGPoint touchPoint = [touch locationInView:self];
   
   assert([self.layer.sublayers count] == 1);
   CALayer * innerLayer = [self.layer.sublayers objectAtIndex:0];
   if ([innerLayer hitTest:touchPoint])
   {
      lastTouchVector_ = [self touchPointToVector:touchPoint];
   }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
   UITouch * touch = [touches anyObject];
   CGPoint touchPoint = [touch locationInView:self];
   
   assert([self.layer.sublayers count] == 1);
   CALayer * innerLayer = [self.layer.sublayers objectAtIndex:0];
   if ([innerLayer hitTest:touchPoint])
   {
      CATransform3D currentTransform = self.layer.sublayerTransform;
      
      CGFloat rotationAngle = [self calculateRotationAngle:touchPoint];
      self.layer.sublayerTransform = CATransform3DRotate(currentTransform, rotationAngle, 0, 0, 1);
   }
}

@end
