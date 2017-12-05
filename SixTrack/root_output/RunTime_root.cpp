#include "TTree.h"
#include "TROOT.h"
#include "RunTime_root.h"

Float_t pretime;
Float_t trtime;
Float_t posttime;

TTree *RunTimeTree;

//Dumps optical functions
extern "C" void RunTimeRootInit()
{
    //Tree stuff
    RunTimeTree = new TTree("RunTime","RunTimeTree");
    RunTimeTree->Branch("pretime",&pretime,"pretime/F");
    RunTimeTree->Branch("trtime",&trtime,"trtime/F");
    RunTimeTree->Branch("posttime",&posttime,"posttime/F");
}

extern "C" void RunTimeRootWrite(Float_t pretime_in, Float_t trtime_in, Float_t posttime_in)
{
    pretime = pretime_in;
    trtime = trtime_in;
    posttime = posttime_in;

    //Do the write
    RunTimeTree->Fill();
}

