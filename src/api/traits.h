/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Distributed under BSD 3-Clause license.                                   *
 * Copyright by The HDF Group.                                               *
 * Copyright by the Illinois Institute of Technology.                        *
 * All rights reserved.                                                      *
 *                                                                           *
 * This file is part of Hermes. The full Hermes copyright notice, including  *
 * terms governing use, modification, and redistribution, is contained in    *
 * the COPYING file, which can be found at the top directory. If you do not  *
 * have access to the file, you may request a copy from help@hdfgroup.org.   *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef HERMES_TRAITS_H
#define HERMES_TRAITS_H

#include <unordered_map>

#include "hermes_types.h"
#include "hermes.h"

namespace hermes {
namespace api {

struct BlobInfo {
  std::string bucket_name;
  std::string blob_name;
};

typedef BlobInfo TraitInput;
struct Trait;
using HermesPtr = std::shared_ptr<Hermes>;

typedef std::function<void(HermesPtr, TraitInput &, Trait *)> OnLinkCallback;
typedef std::function<void(HermesPtr, VBucketID, Trait *)> OnAttachCallback;
typedef std::function<bool(HermesPtr, std::pair<std::string, std::string>,
                      std::pair<std::string, std::string>)> TraitOrder;

struct Trait {
  TraitID id;
  TraitIdArray conflict_traits;
  TraitType type;
  OnAttachCallback onAttachFn;
  OnAttachCallback onDetachFn;
  OnLinkCallback onLinkFn;
  OnLinkCallback onUnlinkFn;
  OnLinkCallback onGetFn;

  Trait() {}
  Trait(TraitID id, TraitIdArray conflict_traits, TraitType type);
};

#define HERMES_FILE_TRAIT 10
#define HERMES_PERSIST_TRAIT 11
#define HERMES_ORDER_TRAIT 12

struct FileMappingTrait : public Trait {
  OnLinkCallback flush_cb;
  OnLinkCallback load_cb;
  std::string filename;
  std::unordered_map<std::string, u64> offset_map;
  FILE *fh;

  FileMappingTrait() {}
  FileMappingTrait(const std::string &filename,
                   std::unordered_map<std::string, u64> &offset_map, FILE *fh,
                   OnLinkCallback flush_cb, OnLinkCallback load_cb);
  void onAttach(HermesPtr hermes, VBucketID id, Trait *trait);
  void onDetach(HermesPtr hermes, VBucketID id, Trait *trait);
  void onLink(HermesPtr hermes, TraitInput &blob, Trait *trait);
  void onUnlink(HermesPtr hermes, TraitInput &blob, Trait *trait);
};

struct PersistTrait : public Trait {
  FileMappingTrait file_mapping;
  bool synchronous;

  explicit PersistTrait(bool synchronous);
  explicit PersistTrait(FileMappingTrait mapping,
                        bool synchronous = false);

  void onAttach(HermesPtr hermes, VBucketID id, Trait *trait);
  void onDetach(HermesPtr hermes, VBucketID id, Trait *trait);
  void onLink(HermesPtr hermes, TraitInput &blob, Trait *trait);
  void onUnlink(HermesPtr hermes, TraitInput &blob, Trait *trait);
};

struct OrderingTrait : public Trait {
 private:
  HermesPtr hermes_;
  std::vector<std::pair<std::string, std::string>> blobs_order_;
  std::vector<int> blobs_customerized_order_;
  void GetNextN(HermesPtr hermes, std::string blob_name,
                std::string bkt_name, u8 num_blob_prefetch);
  void Sort(HermesPtr hermes);
 public:
  u8 num_blob_prefetch_;
  TraitOrder order_func_;
  OrderingTrait(u8 num_blob_prefetch, TraitOrder order_func = nullptr,
                const std::vector<int> &vect = std::vector<int>());
  void onAttach(HermesPtr hermes, VBucketID id, Trait *trait);
  void onDetach(HermesPtr hermes, VBucketID id, Trait *trait);
  void onLink(HermesPtr hermes, TraitInput &blob, Trait *trait);
  void onUnlink(HermesPtr hermes, TraitInput &blob, Trait *trait);
  void onGet(HermesPtr hermes, TraitInput &blob, Trait *trait);
  static bool NameAscend(HermesPtr hermes,
                         const std::pair<std::string, std::string>,
                         const std::pair<std::string, std::string>);
  static bool NameDescend(HermesPtr hermes,
                          const std::pair<std::string, std::string>,
                          const std::pair<std::string, std::string>);

  static bool SizeGreater(HermesPtr hermes,
                          const std::pair<std::string, std::string>,
                          const std::pair<std::string, std::string>);

  static bool SizeLess(HermesPtr hermes,
                       const std::pair<std::string, std::string>,
                       const std::pair<std::string, std::string>);

  static bool Importance(HermesPtr hermes,
                         const std::pair<std::string, std::string>,
                         const std::pair<std::string, std::string>);
};

}  // namespace api
}  // namespace hermes

#endif  // HERMES_TRAITS_H
