//
//  MapVC.h
//  Bicyclette
//
//  Created by Nicolas on 04/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

@class BicycletteCity;
@class Station;

@interface MapVC : UIViewController 

@property NSArray * cities;

@property (nonatomic, readonly) BicycletteCity * currentCity;

- (void) zoomInStation:(Station*)station;

// Hook for faster animation
- (void) setAnnotationsHidden:(BOOL)hidden;

@end
