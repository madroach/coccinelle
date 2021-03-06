 int do_setitimer(int which, struct itimerval *value, 
                 struct itimerval *ovalue)
{
   unsigned long expire;
   cputime_t cputime;
   int k;
   if (ovalue && (k = do_getitimer(which, ovalue)) < 0)
     return k;
   switch (which) {
     case ITIMER_VIRTUAL:
       cputime = timeval_to_cputime(&value->it_value);
      if (cputime_gt(cputime, cputime_zero))
         cputime = cputime_add(cputime,
                                       jiffies_to_cputime(1));
       current->it_virt_value = cputime;
       cputime = timeval_to_cputime(&value->it_interval);
       current->it_virt_incr = cputime;
       break;
     case ITIMER_PROF:
       cputime = timeval_to_cputime(&value->it_value);
        if (cputime_gt(cputime, cputime_zero))
          cputime = cputime_add(cputime,
                                        jiffies_to_cputime(1));
         current->it_prof_value = cputime;
         cputime = timeval_to_cputime(&value->it_interval);
         current->it_prof_incr = cputime;
         break;
       default:
         return -EINVAL;
   }
   return 0;
}