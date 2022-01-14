//
//  GZip.h
//  AdswizzInteractiveAd
//
//  Created by Bogdan Cosescu on 21/10/2019.
//  Copyright © 2019 AdsWizz. All rights reserved.
//

#ifndef GZip_h
#define GZip_h
#ifdef INTERNAL_GZIP
#include <stdio.h>


typedef struct GZipResult {
    unsigned char *data;
    long int sizeOfData;
} GZipResult;

GZipResult gunzip(const unsigned char *data, long int length);
GZipResult gzip(const unsigned char *data, long int length);

#endif
#endif /* GZipp_h */
