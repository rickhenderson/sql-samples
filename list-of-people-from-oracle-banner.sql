-- Note this code was written to run inside Oracle SQL Developer
-- Some of the code was generated by a BI tool but I had to restructure
-- all of the JOIN statements to use the ANSI join format instead of the
-- deprecated (+)= notation generated by Cognos.
-- I also had to make changes to indentation to make it easier to understand.

SELECT distinct 
     Person.Pidm "Pidm", 
     Person.First_Name "First Name",
     Person.Last_Name "Last Name",
     sgbstdn_camp_code "Camp",
     sgbstdn_coll_code_1 "Faculty",
     smrprle_program "Program",
     nvl(T8."Acad Hist Credits",0) + nvl(T9."Current Credits",0) + nvl(T20."LOP Credits",0) "Total Credits" 
FROM sgbstdn

JOIN sfbetrm
ON   sgbstdn_pidm          = sfbetrm_pidm
 AND sgbstdn_term_code_eff = SFBETRM.SFBETRM_TERM_CODE
 
JOIN goremal home_email
     on goremal_pidm = sfbetrm_pidm
JOIN goremal student_email
     on student_email.goremal_pidm = sfbetrm_pidm
JOIN saturn.PERSON 
     on Person.PIDM = sfbetrm_pidm
JOIN SPVINTL
     on spvintl_pidm = sgbstdn_pidm

JOIN SMRPRLE_ADD
     on smrprle_program = sgbstdn_program_1

JOIN STVMAJR
     on stvmajr_code = SGBSTDN_MAJR_CODE_1
     
JOIN SHRDGMR
     on shrdgmr_pidm = person.pidm

JOIN SFRCPLR_ADD
     on sfrcplr_program = sgbstdn_program_1

/* Join Acad History Credits */
left outer Join (select T10.sfbetrm_pidm "Pidm",
                    nvl(sum(T13.swvgrde_credit_hours * 100),0) "Acad Hist Credits"
          from saturn.swvgrde T13,
                  saturn.shrtckn T12,
                  saturn.sgbstdn T11,
                  saturn.sfbetrm T10
          where ((T10.sfbetrm_term_code = :p_EndTerm and 
                      T11.sgbstdn_pidm = T10.sfbetrm_pidm and 
                      T11.sgbstdn_term_code_eff = T10.sfbetrm_term_code and 
                      T11.sgbstdn_levl_code = 'UG' and
                      T10.sfbetrm_ests_code in ('RE', 'LO', 'WK' ,'RN')) or
                      (T10.sfbetrm_term_code = :p_StartTerm and 
                       T11.sgbstdn_pidm = T10.sfbetrm_pidm and 
                       T11.sgbstdn_term_code_eff = T10.sfbetrm_term_code and 
                       T11.sgbstdn_levl_code = 'UG' and
                       T10.sfbetrm_ests_code in ('RE', 'LO', 'WK' ,'RN') and
                       not exists (select null
                                      from saturn.sgbstdn T15,
                                             saturn.sfbetrm T14
                                     where T14.sfbetrm_pidm = T10.sfbetrm_pidm and
                                                T14.sfbetrm_term_code = :p_EndTerm and 
                                                T15.sgbstdn_pidm = T14.sfbetrm_pidm and 
                                                T15.sgbstdn_term_code_eff = T14.sfbetrm_term_code and 
                                                T15.sgbstdn_levl_code = 'UG' and
                                                T14.sfbetrm_ests_code in ('RE', 'LO', 'WK' ,'RN')))) and
                     T12.shrtckn_pidm = T10.sfbetrm_pidm and
                     T12.shrtckn_wlu_course_status in ('F','H','X') and
                     (T12.shrtckn_camp_code != 'I' or
                      (T12.shrtckn_camp_code = 'I' and
                       T12.shrtckn_subj_code = 'NU')) and
                     T13.swvgrde_pidm = T12.shrtckn_pidm and
                     T13.swvgrde_term_code = T12.shrtckn_term_code and
                     T13.swvgrde_tckn_seq_no = T12.shrtckn_seq_no and
                     T13.swvgrde_grde_code_final in ('CR','A+','A','A-','B+','B','B-','C+','C','C-',
                                                                           'D+','D','D-','IP')
                    group by T10.sfbetrm_pidm) T8
               on T8."Pidm" = sfbetrm_pidm

/* Join Current Course Credits */
left outer Join (select T14.sfbetrm_pidm "Pidm",
                    nvl(sum(T16.sfrstcr_credit_hr * 100),0) "Current Credits"
          from saturn.sfrstcr T16,
                  saturn.ssbsect T19,
                  saturn.sgbstdn T15,
                  saturn.sfbetrm T14
          where ((T14.sfbetrm_term_code = :p_EndTerm and 
                      T15.sgbstdn_pidm = T14.sfbetrm_pidm and 
                      T15.sgbstdn_term_code_eff = T14.sfbetrm_term_code and 
                      T15.sgbstdn_levl_code = 'UG' and
                      T14.sfbetrm_ests_code in ('RE', 'LO', 'WK' ,'RN')) or
                      (T14.sfbetrm_term_code = :p_StartTerm and 
                       T15.sgbstdn_pidm = T14.sfbetrm_pidm and 
                       T15.sgbstdn_term_code_eff = T14.sfbetrm_term_code and 
                       T15.sgbstdn_levl_code ='UG' and
                       T14.sfbetrm_ests_code in ('RE', 'LO', 'WK','RN') and
                       not exists (select null
                                      from saturn.sgbstdn T18,
                                             saturn.sfbetrm T17
                                     where T17.sfbetrm_pidm = T14.sfbetrm_pidm and
                                                T17.sfbetrm_term_code = :p_EndTerm and 
                                                T18.sgbstdn_pidm = T17.sfbetrm_pidm and 
                                                T18.sgbstdn_term_code_eff = T17.sfbetrm_term_code and 
                                                T18.sgbstdn_levl_code = 'UG' and
                                                T17.sfbetrm_ests_code in ('RE', 'LO', 'WK' ,'RN'))))and
                     T16.sfrstcr_pidm = T14.sfbetrm_pidm and
                     T16.sfrstcr_rsts_code in ('RE','AU','IP') and
                     (T16.sfrstcr_camp_code != 'I' or
                      (T16.sfrstcr_camp_code = 'I' and
                       T19.ssbsect_subj_code = 'NU')) and
                     T16.sfrstcr_XYZ_course_status in ('F','H','X') and
                     T19.ssbsect_term_code = T16.sfrstcr_term_code and
                     T19.ssbsect_crn = T16.sfrstcr_crn and
                     T19.ssbsect_schd_code in ('F','A') and
                     not exists (select null
                                      from saturn.shrtckn T19
                                      where T19.shrtckn_pidm = T16.sfrstcr_pidm and
                                                 T19.shrtckn_term_code = T16.sfrstcr_term_code and
                                                 T19.shrtckn_crn = T16.sfrstcr_crn)
                    group by T14.sfbetrm_pidm) T9
               on t9."Pidm" = sgbstdn_pidm
               
/* Join LOP / transfer Credits */               
left outer join  (select T21.sfbetrm_pidm "Pidm",
                    nvl(sum(T23.shrtrce_credit_hours * 100),0) "LOP Credits"
          from saturn.shrtrce T23,
                  saturn.sgbstdn T22,
                  saturn.sfbetrm T21
          where ((T21.sfbetrm_term_code = :p_EndTerm and 
                      T22.sgbstdn_pidm = T21.sfbetrm_pidm and 
                      T22.sgbstdn_term_code_eff = T21.sfbetrm_term_code and 
                      T22.sgbstdn_levl_code = 'UG' and
                      T21.sfbetrm_ests_code in ('RE', 'LO', 'WK' ,'RN')) or
                      (T21.sfbetrm_term_code = :p_StartTerm and 
                       T22.sgbstdn_pidm = T21.sfbetrm_pidm and 
                       T22.sgbstdn_term_code_eff = T21.sfbetrm_term_code and 
                       T22.sgbstdn_levl_code = 'UG' and
                       T21.sfbetrm_ests_code in ('RE', 'LO', 'WK','RN' ) and
                       not exists (select null
                                      from saturn.sgbstdn T25,
                                             saturn.sfbetrm T24
                                     where T24.sfbetrm_pidm = T21.sfbetrm_pidm and
                                                T24.sfbetrm_term_code = :p_EndTerm and 
                                                T25.sgbstdn_pidm = T24.sfbetrm_pidm and 
                                                T25.sgbstdn_levl_code = 'UG' and
                                                T25.sgbstdn_term_code_eff = T24.sfbetrm_term_code and 
                                                T24.sfbetrm_ests_code in ('RE', 'LO', 'WK' ,'RN'))))and
                     T23.shrtrce_pidm = T21.sfbetrm_pidm and
                     (T23.shrtrce_gmod_code = 'T' or
                      (T23.shrtrce_gmod_code = 'L' and
                       T23.shrtrce_wlu_course_status in ('F','H','X') and
                       T23.shrtrce_grde_code in ('CR','A+','A','A-','B+','B','B-','C+','C','C-',
                                                                           'D+','D','D-','IP')))
                    group by T21.sfbetrm_pidm) T20
                    on T20."Pidm" = person.pidm
               
where sgbstdn_term_code_eff in (:p_StartTerm, :p_EndTerm)
AND sgbstdn_levl_code = 'UG'
and

/* A or B, including C and D as B */
(:p_Campus = '%' or
             (:p_Campus = 'A' and sgbstdn_camp_code not in ('C','D')) or
             (:p_Campus = 'B' and sgbstdn_camp_code in ('C','D')))
             
and smrprle_add.smrprle_ptyp_code in ('G', 'H')
and sfbetrm_ests_code in ('RE','LO','WK','RN') 
and home_email.goremal_emal_code = 'APH1' and home_email.goremal_status_ind = 'A'
and student_email.goremal_emal_code = 'SXYZ' and student_email.goremal_status_ind = 'A'

/* Did not graduate in Omitted Term */
and 
not exists (select null
                             from saturn.shrdgmr T5
                             where T5.shrdgmr_pidm = sfbetrm_pidm and
                                        to_char(T5.shrdgmr_grad_date,'YYYYMM') = :p_GradYearOmit)
and 


(      
     ( /* Does potentially graduate in the Specified Grad Year */
       exists (select null
                        from saturn.shrdgmr T6
                        where T6.shrdgmr_pidm = sfbetrm_pidm and
                                   to_char(T6.shrdgmr_grad_date,'YYYY') = :p_GradYear and
                                  T6.shrdgmr_degs_code in ('A','G','X')))
OR
 ((
          /* Honors Year 5 from (specific program) require at least 2000 credits */
          ("SMRPRLE_ADD"."SMRPRLE_PTYP_CODE"       ='H'
          AND "SGBSTDN"."SGBSTDN_XYZ_YLVL_CODE"        ='5'
          and "SGBSTDN"."SGBSTDN_CAMP_CODE" = 'I'
          and nvl(T8."Acad Hist Credits",0)+nvl(T9."Current Credits",0)+
                       nvl(T20."LOP Credits",0) >= 2000)
                       
  OR      /* Honours Year 5 not from (specific program)
             require at least 2500 credits */
          ("SMRPRLE_ADD"."SMRPRLE_PTYP_CODE"       ='H'
          AND "SGBSTDN"."SGBSTDN_XYZ_YLVL_CODE"        ='5'
          and "SGBSTDN"."SGBSTDN_CAMP_CODE" != 'I'
          and nvl(T8."Acad Hist Credits",0)+nvl(T9."Current Credits",0)+
                       nvl(T20."LOP Credits",0) >= 2500)
                       
  OR  /* Honours Year 4 with no valid 5th year needs at least 2000 credits */     
     ("SMRPRLE_ADD"."SMRPRLE_PTYP_CODE"        ='H'
     AND "SGBSTDN"."SGBSTDN_XYZ_YLVL_CODE"        ='4' 
     AND "SFRCPLR_ADD"."SFRCPLR_FIFTH_VALID_YR"  IS NULL
     and nvl(T8."Acad Hist Credits",0)+nvl(T9."Current Credits",0)+
                       nvl(T20."LOP Credits",0) >= 2000
    )
    
  OR /* General Year 4 require at least 2000 credits */   
     ("SMRPRLE_ADD"."SMRPRLE_PTYP_CODE"        ='G'
     AND "SGBSTDN"."SGBSTDN_XYZ_YLVL_CODE"        ='4'
     and nvl(T8."Acad Hist Credits",0)+nvl(T9."Current Credits",0)+
                       nvl(T20."LOP Credits",0) >= 2000
     )
  OR /* General Year 3 with no valid 4th year requires at least 1500 credits */
     ("SMRPRLE_ADD"."SMRPRLE_PTYP_CODE"        ='G'
          AND "SGBSTDN"."SGBSTDN_XYZ_YLVL_CODE"        ='3')
          AND "SFRCPLR_ADD"."SFRCPLR_FOURTH_VALID_YR" IS NULL
          and nvl(T8."Acad Hist Credits",0)+nvl(T9."Current Credits",0)+
                       nvl(T20."LOP Credits",0) >= 1500
     )
     
     ) /* end credits requirements filter */
) /* end criteria for current grad year with credit counts */

ORDER by "Last Name"
;
