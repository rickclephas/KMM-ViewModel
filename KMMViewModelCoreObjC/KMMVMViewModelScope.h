//
//  KMMVMViewModelScope.h
//  KMMViewModelCoreObjC
//
//  Created by Rick Clephas on 27/11/2022.
//

#ifndef KMMVMViewModelScope_h
#define KMMVMViewModelScope_h

#import <Foundation/Foundation.h>

__attribute__((swift_name("ViewModelScope")))
@protocol KMMVMViewModelScope
- (void)increaseSubscriptionCount;
- (void)decreaseSubscriptionCount;
- (void)setPropertyAccess:(void (^ _Nonnull)(NSObject * _Nonnull))propertyAccess;
- (void)setPropertyWillSet:(void (^ _Nonnull)(NSObject * _Nonnull))propertyWillSet;
- (void)setPropertyDidSet:(void (^ _Nonnull)(NSObject * _Nonnull))propertyDidSet;
- (void)cancel;
@end

#endif /* KMMVMViewModelScope_h */
