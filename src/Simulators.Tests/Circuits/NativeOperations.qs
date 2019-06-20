namespace NativeOperations
{
    operation IntrinsicBody () : String
    {
        body intrinsic;
    }

    operation DefaultBody () : String
    {
        return "hello";
    }

    operation IntrinsicBodyGeneric<'T>(arg: 'T) : String
    {
        body intrinsic;
    }

    operation DefaultBodyGeneric<'T>(arg: 'T) : 'T
    {
        return arg;
    }
}
