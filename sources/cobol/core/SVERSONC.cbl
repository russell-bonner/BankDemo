      *****************************************************************
      *                                                               *
      * Copyright (C) 2010-2021 Micro Focus.  All Rights Reserved     *
      * This software may be used, modified, and distributed          *
      * (provided this notice is included without modification)       *
      * solely for internal demonstration purposes with other         *
      * Micro Focus software, and is otherwise subject to the EULA at *
      * https://www.microfocus.com/en-us/legal/software-licensing.    *
      *                                                               *
      * THIS SOFTWARE IS PROVIDED "AS IS" AND ALL IMPLIED             *
      * WARRANTIES, INCLUDING THE IMPLIED WARRANTIES OF               *
      * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE,         *
      * SHALL NOT APPLY.                                              *
      * TO THE EXTENT PERMITTED BY LAW, IN NO EVENT WILL              *
      * MICRO FOCUS HAVE ANY LIABILITY WHATSOEVER IN CONNECTION       *
      * WITH THIS SOFTWARE.                                           *
      *                                                               *
      *****************************************************************

      *****************************************************************
      * Program:     SVERSONC.CBL                                     *
      * Layer:       Screen handling                                  *
      * Function:    Populate screen titles (CICS version)            *
      *****************************************************************

       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           SVERSONC.
       DATE-WRITTEN.
           March 2023.
       DATE-COMPILED.
           Today.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *****************************************************************
      * Version to show on screens                                    *
      *****************************************************************
       01  WS-VERSION                              PIC X(7)
           VALUE ' V6.01d'.

       LINKAGE SECTION.
       01  DFHCOMMAREA.
         05  LK-VERSION                           PIC X(7).          

       PROCEDURE DIVISION.

           MOVE WS-VERSION TO LK-VERSION.

      *****************************************************************
      * Now we have to have finished and can return to our invoker.   *
      *****************************************************************
           EXEC CICS
                RETURN
           END-EXEC.
           GOBACK.

      * $ Version 5.99c sequenced on Wednesday 3 Mar 2011 at 1:00pm

