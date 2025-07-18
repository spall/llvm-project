//===--- GeneratePCH.cpp - Sema Consumer for PCH Generation -----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//  This file defines the PCHGenerator, which as a SemaConsumer that generates
//  a PCH file.
//
//===----------------------------------------------------------------------===//

#include "clang/AST/ASTContext.h"
#include "clang/Basic/DiagnosticFrontend.h"
#include "clang/Lex/HeaderSearch.h"
#include "clang/Lex/HeaderSearchOptions.h"
#include "clang/Lex/Preprocessor.h"
#include "clang/Sema/SemaConsumer.h"
#include "clang/Serialization/ASTWriter.h"
#include "llvm/Bitstream/BitstreamWriter.h"

using namespace clang;

PCHGenerator::PCHGenerator(
    Preprocessor &PP, ModuleCache &ModCache, StringRef OutputFile,
    StringRef isysroot, std::shared_ptr<PCHBuffer> Buffer,
    const CodeGenOptions &CodeGenOpts,
    ArrayRef<std::shared_ptr<ModuleFileExtension>> Extensions,
    bool AllowASTWithErrors, bool IncludeTimestamps,
    bool BuildingImplicitModule, bool ShouldCacheASTInMemory,
    bool GeneratingReducedBMI)
    : PP(PP), Subject(&PP), OutputFile(OutputFile), isysroot(isysroot.str()),
      Buffer(std::move(Buffer)), Stream(this->Buffer->Data),
      Writer(Stream, this->Buffer->Data, ModCache, CodeGenOpts, Extensions,
             IncludeTimestamps, BuildingImplicitModule, GeneratingReducedBMI),
      AllowASTWithErrors(AllowASTWithErrors),
      ShouldCacheASTInMemory(ShouldCacheASTInMemory) {
  this->Buffer->IsComplete = false;
}

PCHGenerator::~PCHGenerator() {
}

Module *PCHGenerator::getEmittingModule(ASTContext &) {
  Module *M = nullptr;

  if (PP.getLangOpts().isCompilingModule()) {
    M = PP.getHeaderSearchInfo().lookupModule(PP.getLangOpts().CurrentModule,
                                              SourceLocation(),
                                              /*AllowSearch*/ false);
    if (!M)
      assert(PP.getDiagnostics().hasErrorOccurred() &&
             "emitting module but current module doesn't exist");
  }

  return M;
}

DiagnosticsEngine &PCHGenerator::getDiagnostics() const {
  return PP.getDiagnostics();
}

void PCHGenerator::InitializeSema(Sema &S) {
  if (!PP.getHeaderSearchInfo()
           .getHeaderSearchOpts()
           .ModulesSerializeOnlyPreprocessor)
    Subject = &S;
}

void PCHGenerator::HandleTranslationUnit(ASTContext &Ctx) {
  // Don't create a PCH if there were fatal failures during module loading.
  if (PP.getModuleLoader().HadFatalFailure)
    return;

  bool hasErrors = PP.getDiagnostics().hasErrorOccurred();
  if (hasErrors && !AllowASTWithErrors)
    return;

  Module *Module = getEmittingModule(Ctx);

  // Errors that do not prevent the PCH from being written should not cause the
  // overall compilation to fail either.
  if (AllowASTWithErrors)
    PP.getDiagnostics().getClient()->clear();

  Buffer->Signature = Writer.WriteAST(Subject, OutputFile, Module, isysroot,
                                      ShouldCacheASTInMemory);

  Buffer->IsComplete = true;
}

ASTMutationListener *PCHGenerator::GetASTMutationListener() {
  return &Writer;
}

ASTDeserializationListener *PCHGenerator::GetASTDeserializationListener() {
  return &Writer;
}

void PCHGenerator::anchor() {}

CXX20ModulesGenerator::CXX20ModulesGenerator(Preprocessor &PP,
                                             ModuleCache &ModCache,
                                             StringRef OutputFile,
                                             const CodeGenOptions &CodeGenOpts,
                                             bool GeneratingReducedBMI,
                                             bool AllowASTWithErrors)
    : PCHGenerator(
          PP, ModCache, OutputFile, llvm::StringRef(),
          std::make_shared<PCHBuffer>(), CodeGenOpts,
          /*Extensions=*/ArrayRef<std::shared_ptr<ModuleFileExtension>>(),
          AllowASTWithErrors, /*IncludeTimestamps=*/false,
          /*BuildingImplicitModule=*/false, /*ShouldCacheASTInMemory=*/false,
          GeneratingReducedBMI) {}

Module *CXX20ModulesGenerator::getEmittingModule(ASTContext &Ctx) {
  Module *M = Ctx.getCurrentNamedModule();
  assert(M && M->isNamedModuleUnit() &&
         "CXX20ModulesGenerator should only be used with C++20 Named modules.");
  return M;
}

void CXX20ModulesGenerator::HandleTranslationUnit(ASTContext &Ctx) {
  PCHGenerator::HandleTranslationUnit(Ctx);

  if (!isComplete())
    return;

  std::error_code EC;
  auto OS = std::make_unique<llvm::raw_fd_ostream>(getOutputFile(), EC);
  if (EC) {
    getDiagnostics().Report(diag::err_fe_unable_to_open_output)
        << getOutputFile() << EC.message() << "\n";
    return;
  }

  *OS << getBufferPtr()->Data;
  OS->flush();
}

void CXX20ModulesGenerator::anchor() {}

void ReducedBMIGenerator::anchor() {}
