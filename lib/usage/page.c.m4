dnl
dnl lib/usage/page.c template.
dnl
dnl Copyright (C) 2010 Nikolai Kondrashov
dnl
dnl This file is part of hidrd.
dnl
dnl Hidrd is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; either version 2 of the License, or
dnl (at your option) any later version.
dnl
dnl Hidrd is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with hidrd; if not, write to the Free Software
dnl Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
dnl
dnl
include(`m4/hidrd/util.m4')dnl
dnl
`/** @file
 * @brief HID report descriptor - usage pages
 *
 * vim:nomodifiable
 *
 * ************* DO NOT EDIT ***************
 * This file is autogenerated from page.c.m4
 * *****************************************
 *
 * Copyright (C) 2009-2010 Nikolai Kondrashov
 *
 * This file is part of hidrd.
 *
 * Hidrd is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Hidrd is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with hidrd; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 * @author Nikolai Kondrashov <spbnick@gmail.com>
 *
 * @(#) $Id: page.c 103 2010-01-18 21:04:26Z spb_nick $
 */

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "hidrd/util/hex.h"
#include "hidrd/util/str.h"
#include "hidrd/util/tkn.h"
#include "hidrd/usage/page.h"

'pushdef(`PAGE_SET',
`ifelse(eval(PAGE_SET_RANGE_NUM($1) > 1), 1,
bool
hidrd_usage_page_$1(hidrd_usage_page page)
{
    assert(hidrd_usage_page_valid(page));
PAGE_SET_RANGE_CHECK($1)
}

)')dnl
include(`db/usage/page_set.m4')dnl
popdef(`PAGE_SET')dnl
`
#if defined(HIDRD_WITH_TOKENS) || defined(HIDRD_WITH_NAMES)

typedef struct page_desc {
    hidrd_usage_page    page;
#ifdef HIDRD_WITH_TOKENS
    const char         *token;
#endif
#ifdef HIDRD_WITH_NAMES
    const char         *name;
#endif
} page_desc;

#ifdef HIDRD_WITH_TOKENS
#define PAGE_TOKEN(_token)  .token = _token,
#else
#define PAGE_TOKEN(_token)
#endif

#ifdef HIDRD_WITH_NAMES
#define PAGE_NAME(_name)    .name = _name,
#else
#define PAGE_NAME(_name)
#endif

static const page_desc desc_list[] = {

#define PAGE(_TOKEN, _token, _name) \
    {.page = HIDRD_USAGE_PAGE_##_TOKEN,     \
     PAGE_TOKEN(#_token) PAGE_NAME(_name)}

    PAGE(UNDEFINED, undefined, "undefined"),

'dnl
define(`PAGE', `    `PAGE'(uppercase($2), $2, "$3"),
')dnl
include(`db/usage/page.m4')dnl
`
#undef PAGE
};

#undef PAGE_NAME
#undef PAGE_TOKEN

static const size_t desc_num = sizeof(desc_list) / sizeof(*desc_list);


static const page_desc *
lookup_desc_by_num(hidrd_usage_page page)
{
    size_t  i;

    assert(hidrd_usage_page_valid(page));

    for (i = 0; i < desc_num; i++)
        if (desc_list[i].page == page)
            return &desc_list[i];

    return NULL;
}


char *
hidrd_usage_page_to_hex(hidrd_usage_page page)
{
    assert(hidrd_usage_page_valid(page));

    return hidrd_hex_u16_to_str((uint16_t)page);
}


char *
hidrd_usage_page_to_bhex(hidrd_usage_page page)
{
    assert(hidrd_usage_page_valid(page));

    return hidrd_hex_u16_to_bstr((uint16_t)page);
}


bool
hidrd_usage_page_from_hex(hidrd_usage_page *ppage, const char *hex)
{
    uint16_t    page;

    if (!hidrd_hex_u16_from_str(&page, hex))
        return false;

    if (ppage != NULL)
        *ppage = (hidrd_usage_page)page;

    return true;
}


bool
hidrd_usage_page_from_bstr(hidrd_usage_page *ppage, const char *str)
{
    uint16_t    page;

    if (!hidrd_num_u16_from_bstr(&page, str))
        return false;

    if (ppage != NULL)
        *ppage = (hidrd_usage_page)page;

    return true;
}


#ifdef HIDRD_WITH_TOKENS

const char *
hidrd_usage_page_to_token(hidrd_usage_page page)
{
    const page_desc    *desc;

    assert(hidrd_usage_page_valid(page));
    desc = lookup_desc_by_num(page);

    return (desc != NULL) ? desc->token : NULL;
}


char *
hidrd_usage_page_to_token_or_hex(hidrd_usage_page page)
{
    const char         *token;

    assert(hidrd_usage_page_valid(page));

    token = hidrd_usage_page_to_token(page);

    return (token != NULL) ? strdup(token) : hidrd_usage_page_to_hex(page);
}


char *
hidrd_usage_page_to_token_or_bhex(hidrd_usage_page page)
{
    const char         *token;

    assert(hidrd_usage_page_valid(page));

    token = hidrd_usage_page_to_token(page);

    return (token != NULL) ? strdup(token) : hidrd_usage_page_to_bhex(page);
}


bool
hidrd_usage_page_from_token(hidrd_usage_page *ppage, const char *token)
{
    const char *tkn;
    size_t      len;
    size_t      i;

    assert(token != NULL);

    if (!hidrd_tkn_strip(&tkn, &len, token))
        return false;

    for (i = 0; i < desc_num; i++)
        if (hidrd_str_ncasecmpn(desc_list[i].token, tkn, len) == 0)
        {
            if (ppage != NULL)
                *ppage = hidrd_usage_page_validate(desc_list[i].page);
            return true;
        }

    return false;
}


bool
hidrd_usage_page_from_token_or_hex(hidrd_usage_page    *ppage,
                                   const char          *token_or_hex)
{
    assert(token_or_hex != NULL);

    return hidrd_usage_page_from_token(ppage, token_or_hex) ||
           hidrd_usage_page_from_hex(ppage, token_or_hex);
}


bool
hidrd_usage_page_from_token_or_bstr(hidrd_usage_page   *ppage,
                                    const char         *token_or_bstr)
{
    assert(token_or_bstr != NULL);

    return hidrd_usage_page_from_token(ppage, token_or_bstr) ||
           hidrd_usage_page_from_bstr(ppage, token_or_bstr);
}

#endif /* HIDRD_WITH_TOKENS */

#ifdef HIDRD_WITH_NAMES

const char *
hidrd_usage_page_name(hidrd_usage_page page)
{
    const page_desc    *desc;

    assert(hidrd_usage_page_valid(page));

    desc = lookup_desc_by_num(page);

    return (desc != NULL) ? desc->name : NULL;
}

#ifdef HIDRD_WITH_TOKENS

char *
hidrd_usage_page_desc(hidrd_usage_page page)
{
    char       *result      = NULL;
    char       *str         = NULL;
    char       *new_str     = NULL;
    const char *name;

    assert(hidrd_usage_page_valid(page));

    name = hidrd_usage_page_name(page);
    str = (name == NULL) ? strdup("") : strdup(name);

'changequote([,])[
#define MAP(_token, _name) \
    do {                                                    \
        if (!hidrd_usage_page_##_token(page))               \
            break;                                          \
                                                            \
        if (asprintf(&new_str,                              \
                     ((*str == '\0') ? "%s%s" : "%s, %s"),  \
                     str, _name) < 0)                       \
            goto cleanup;                                   \
                                                            \
        free(str);                                          \
        str = new_str;                                      \
        new_str = NULL;                                     \
    } while (0)
]changequote(`,')`

'pushdef(`PAGE_SET',
`    MAP($1, "$2");
')dnl
include(`db/usage/page_set.m4')dnl
popdef(`PAGE_SET')`
    result = str;
    str = NULL;

cleanup:

    free(new_str);
    free(str);

    return result;
}

#endif /* HIDRD_WITH_TOKENS */

#endif /* HIDRD_WITH_NAMES */

#endif /* defined HIDRD_WITH_TOKENS || defined HIDRD_WITH_NAMES */
'dnl
