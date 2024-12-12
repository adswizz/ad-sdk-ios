//
//  XMLValidation.h
//  AdCore
//
//  Created by Bogdan Cosescu on 12/03/2019.
//  Copyright © 2019 AdsWizz, inc. All rights reserved.
//

#ifndef XMLValidation_h
#define XMLValidation_h
#ifdef INTERNAL

#include <stdio.h>
#include <libxml/parser.h>
#include <libxml/xmlschemas.h>

typedef struct XMLResult {
    int code;
    char *msg;
} XMLResult;

XMLResult isXMLValid(const xmlDocPtr doc, const char *schema_filename);

#endif
#endif /* XMLValidation_h */
