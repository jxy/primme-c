/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 3.0.12
 *
 * This file is not intended to be easily readable and contains a number of
 * coding conventions designed to improve portability and efficiency. Do not make
 * changes to this file unless you know what you are doing--modify the SWIG
 * interface file instead.
 * ----------------------------------------------------------------------------- */

#ifndef SWIG_Primme_WRAP_H_
#define SWIG_Primme_WRAP_H_

#include <map>
#include <string>


class SwigDirector_PrimmeParams : public PrimmeParams, public Swig::Director {

public:
    SwigDirector_PrimmeParams(PyObject *self);
    virtual ~SwigDirector_PrimmeParams();
    virtual void matvec(int len1YD, int len2YD, int ldYD, float *yd, int len1XD, int len2XD, int ldXD, float *xd);
    virtual void matvec(int len1YD, int len2YD, int ldYD, std::complex< float > *yd, int len1XD, int len2XD, int ldXD, std::complex< float > *xd);
    virtual void matvec(int len1YD, int len2YD, int ldYD, double *yd, int len1XD, int len2XD, int ldXD, double *xd);
    virtual void matvec(int len1YD, int len2YD, int ldYD, std::complex< double > *yd, int len1XD, int len2XD, int ldXD, std::complex< double > *xd);
    virtual void prevec(int len1YD, int len2YD, int ldYD, float *yd, int len1XD, int len2XD, int ldXD, float *xd);
    virtual void prevec(int len1YD, int len2YD, int ldYD, std::complex< float > *yd, int len1XD, int len2XD, int ldXD, std::complex< float > *xd);
    virtual void prevec(int len1YD, int len2YD, int ldYD, double *yd, int len1XD, int len2XD, int ldXD, double *xd);
    virtual void prevec(int len1YD, int len2YD, int ldYD, std::complex< double > *yd, int len1XD, int len2XD, int ldXD, std::complex< double > *xd);
    virtual void globalSum(int lenYD, float *yd, int lenXD, float *xd);
    virtual void globalSum(int lenYD, double *yd, int lenXD, double *xd);
    virtual void mon(int lenbasisEvals, float *basisEvals, int lenbasisFlags, int *basisFlags, int leniblock, int *iblock, int lenbasisNorms, float *basisNorms, int numConverged, int lenlockedEvals, float *lockedEvals, int lenlockedFlags, int *lockedFlags, int lenlockedNorms, float *lockedNorms, int inner_its, float LSRes, int event);
    virtual void mon(int lenbasisEvals, double *basisEvals, int lenbasisFlags, int *basisFlags, int leniblock, int *iblock, int lenbasisNorms, double *basisNorms, int numConverged, int lenlockedEvals, double *lockedEvals, int lenlockedFlags, int *lockedFlags, int lenlockedNorms, double *lockedNorms, int inner_its, double LSRes, int event);

/* Internal director utilities */
public:
    bool swig_get_inner(const char *swig_protected_method_name) const {
      std::map<std::string, bool>::const_iterator iv = swig_inner.find(swig_protected_method_name);
      return (iv != swig_inner.end() ? iv->second : false);
    }
    void swig_set_inner(const char *swig_protected_method_name, bool swig_val) const {
      swig_inner[swig_protected_method_name] = swig_val;
    }
private:
    mutable std::map<std::string, bool> swig_inner;

#if defined(SWIG_PYTHON_DIRECTOR_VTABLE)
/* VTable implementation */
    PyObject *swig_get_method(size_t method_index, const char *method_name) const {
      PyObject *method = vtable[method_index];
      if (!method) {
        swig::SwigVar_PyObject name = SWIG_Python_str_FromChar(method_name);
        method = PyObject_GetAttr(swig_get_self(), name);
        if (!method) {
          std::string msg = "Method in class PrimmeParams doesn't exist, undefined ";
          msg += method_name;
          Swig::DirectorMethodException::raise(msg.c_str());
        }
        vtable[method_index] = method;
      }
      return method;
    }
private:
    mutable swig::SwigVar_PyObject vtable[12];
#endif

};


class SwigDirector_PrimmeSvdsParams : public PrimmeSvdsParams, public Swig::Director {

public:
    SwigDirector_PrimmeSvdsParams(PyObject *self);
    virtual ~SwigDirector_PrimmeSvdsParams();
    virtual void matvec(int len1YD, int len2YD, int ldYD, float *yd, int len1XD, int len2XD, int ldXD, float *xd, int transpose);
    virtual void matvec(int len1YD, int len2YD, int ldYD, std::complex< float > *yd, int len1XD, int len2XD, int ldXD, std::complex< float > *xd, int transpose);
    virtual void matvec(int len1YD, int len2YD, int ldYD, double *yd, int len1XD, int len2XD, int ldXD, double *xd, int transpose);
    virtual void matvec(int len1YD, int len2YD, int ldYD, std::complex< double > *yd, int len1XD, int len2XD, int ldXD, std::complex< double > *xd, int transpose);
    virtual void prevec(int len1YD, int len2YD, int ldYD, float *yd, int len1XD, int len2XD, int ldXD, float *xd, int mode);
    virtual void prevec(int len1YD, int len2YD, int ldYD, std::complex< float > *yd, int len1XD, int len2XD, int ldXD, std::complex< float > *xd, int mode);
    virtual void prevec(int len1YD, int len2YD, int ldYD, double *yd, int len1XD, int len2XD, int ldXD, double *xd, int mode);
    virtual void prevec(int len1YD, int len2YD, int ldYD, std::complex< double > *yd, int len1XD, int len2XD, int ldXD, std::complex< double > *xd, int mode);
    virtual void globalSum(int lenYD, float *yd, int lenXD, float *xd);
    virtual void globalSum(int lenYD, double *yd, int lenXD, double *xd);
    virtual void mon(int lenbasisSvals, float *basisSvals, int lenbasisFlags, int *basisFlags, int leniblock, int *iblock, int lenbasisNorms, float *basisNorms, int numConverged, int lenlockedSvals, float *lockedSvals, int lenlockedFlags, int *lockedFlags, int lenlockedNorms, float *lockedNorms, int inner_its, float LSRes, int event, int stage);
    virtual void mon(int lenbasisSvals, double *basisSvals, int lenbasisFlags, int *basisFlags, int leniblock, int *iblock, int lenbasisNorms, double *basisNorms, int numConverged, int lenlockedSvals, double *lockedSvals, int lenlockedFlags, int *lockedFlags, int lenlockedNorms, double *lockedNorms, int inner_its, double LSRes, int event, int stage);

/* Internal director utilities */
public:
    bool swig_get_inner(const char *swig_protected_method_name) const {
      std::map<std::string, bool>::const_iterator iv = swig_inner.find(swig_protected_method_name);
      return (iv != swig_inner.end() ? iv->second : false);
    }
    void swig_set_inner(const char *swig_protected_method_name, bool swig_val) const {
      swig_inner[swig_protected_method_name] = swig_val;
    }
private:
    mutable std::map<std::string, bool> swig_inner;

#if defined(SWIG_PYTHON_DIRECTOR_VTABLE)
/* VTable implementation */
    PyObject *swig_get_method(size_t method_index, const char *method_name) const {
      PyObject *method = vtable[method_index];
      if (!method) {
        swig::SwigVar_PyObject name = SWIG_Python_str_FromChar(method_name);
        method = PyObject_GetAttr(swig_get_self(), name);
        if (!method) {
          std::string msg = "Method in class PrimmeSvdsParams doesn't exist, undefined ";
          msg += method_name;
          Swig::DirectorMethodException::raise(msg.c_str());
        }
        vtable[method_index] = method;
      }
      return method;
    }
private:
    mutable swig::SwigVar_PyObject vtable[12];
#endif

};


#endif