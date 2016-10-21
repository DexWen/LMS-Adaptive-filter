/*
 * zx_lms.h
 *
 *  Created on: 2013-8-4
 *      Author: monkeyzx
 */

#ifndef ZX_LMS_H_
#define ZX_LMS_H_

/*
 * methods for @lms_st.method
 */
#define STOCHASTIC           (0x01)     /* 随机梯度下降 */
#define BATCH                (0x02)     /* BATCH梯度下降 */

struct lms_st {
	short method;       /* 0/1 */
	double *x;          /* features, x0,...,x[n-1] */
	int n;              /* dimension of features */
	double *y;          /* given output, y0,..,y[m-1] */
	int m;              /* number of data set */
	double *weight;     /* weighs that want to train by using LMS, w0,w1,..,w[n-1] */
	double lrate;       /* learning rate */
	double threshhold;  /* if error < threshold, stop iteration */
	int max_iter;       /* if iter numbers > max_iter, stop iteration,
	                       if max_iter<0, then max_iter is unused */
};

extern void zx_lms(void);

#endif /* ZX_LMS_H_ */
