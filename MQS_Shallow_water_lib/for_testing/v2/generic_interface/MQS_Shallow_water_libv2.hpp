#include "MatlabTypesInterface.hpp"


matlab::data::Array arcInterpolator(std::shared_ptr<MATLABControllerType> _matlabPtr, matlab::data::Array arg1, matlab::data::Array arg2, matlab::data::Array arg3, matlab::data::Array arg4) { 
    matlab::data::ArrayFactory _arrayFactory;
    std::vector<matlab::data::Array> _args = {
        arg1,
        arg2,
        arg3,
        arg4 };
    matlab::data::Array _result = _matlabPtr->feval(u"arcInterpolator", _args);
    return _result;
}