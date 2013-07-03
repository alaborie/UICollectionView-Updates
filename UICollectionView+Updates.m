/*
 Copyright (c) 2012 Alexandre Laborie

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <objc/runtime.h>

#import "UICollectionView+Updates.h"

@interface UpdateProxy : NSProxy
{
}

@property (nonatomic, weak, readwrite) id target;
@property (nonatomic, strong, readwrite) NSMutableArray *invocationsList;

- (id)initWithTarget:(id)target;

@end

@implementation UpdateProxy

#pragma mark - Lifecycle

- (id)init
{
    return nil;
}

- (id)initWithTarget:(id)target
{
    NSParameterAssert(target != nil);
    if (self != nil) {
        self.target = target;
        self.invocationsList = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - NSProxy

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [self.invocationsList addObject:invocation];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    return [self.target methodSignatureForSelector:selector];
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -

static char kUICollectionViewUpdateProxyKey;

@implementation UICollectionView (Updates)

- (void)beginUpdates
{
    UpdateProxy *updateProxy = [[UpdateProxy alloc] initWithTarget:self];

    objc_setAssociatedObject(self, &kUICollectionViewUpdateProxyKey, updateProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)endUpdates
{
    void (^updateBlock)() = ^{
        UpdateProxy *updateProxy = [self updateProxy];

        [updateProxy.invocationsList makeObjectsPerformSelector:@selector(invokeWithTarget:) withObject:self];
    };
    void (^completionBlock)(BOOL finished) = ^(BOOL finished) {
        objc_setAssociatedObject(self, &kUICollectionViewUpdateProxyKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    };

    [self performBatchUpdates:updateBlock completion:completionBlock];
}

- (id)updateProxy
{
    return objc_getAssociatedObject(self, &kUICollectionViewUpdateProxyKey);
}

@end
